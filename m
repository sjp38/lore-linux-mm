In-Reply-To: <20070627115056.GW14224@think.oraclecorp.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au> <20070626092309.GF31489@sgi.com> <20070626123449.GM14224@think.oraclecorp.com> <20070627053245.GA6033@wotan.suse.de> <20070627115056.GW14224@think.oraclecorp.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Message-Id: <31B65C6A-BECB-4B95-B2D8-ADF422AA6B77@cam.ac.uk>
Content-Transfer-Encoding: 7bit
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: [RFC] fsblock
Date: Wed, 27 Jun 2007 16:18:32 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, David Chinner <dgc@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 27 Jun 2007, at 12:50, Chris Mason wrote:
> On Wed, Jun 27, 2007 at 07:32:45AM +0200, Nick Piggin wrote:
>> On Tue, Jun 26, 2007 at 08:34:49AM -0400, Chris Mason wrote:
>>> On Tue, Jun 26, 2007 at 07:23:09PM +1000, David Chinner wrote:
>>>> On Tue, Jun 26, 2007 at 01:55:11PM +1000, Nick Piggin wrote:
>>>
>>> [ ... fsblocks vs extent range mapping ]
>>>
>>>> iomaps can double as range locks simply because iomaps are
>>>> expressions of ranges within the file.  Seeing as you can only
>>>> access a given range exclusively to modify it, inserting an empty
>>>> mapping into the tree as a range lock gives an effective method of
>>>> allowing safe parallel reads, writes and allocation into the file.
>>>>
>>>> The fsblocks and the vm page cache interface cannot be used to
>>>> facilitate this because a radix tree is the wrong type of tree to
>>>> store this information in. A sparse, range based tree (e.g. btree)
>>>> is the right way to do this and it matches very well with
>>>> a range based API.
>>>
>>> I'm really not against the extent based page cache idea, but I  
>>> kind of
>>> assumed it would be too big a change for this kind of generic  
>>> setup.  At
>>> any rate, if we'd like to do it, it may be best to ditch the idea of
>>> "attach mapping information to a page", and switch to "lookup  
>>> mapping
>>> information and range locking for a page".
>>
>> Well the get_block equivalent API is extent based one now, and I'll
>> look at what is required in making map_fsblock a more generic call
>> that could be used for an extent-based scheme.
>>
>> An extent based thing IMO really isn't appropriate as the main  
>> generic
>> layer here though. If it is really useful and popular, then it could
>> be turned into generic code and sit along side fsblock or underneath
>> fsblock...
>
> Lets look at a typical example of how IO actually gets done today,
> starting with sys_write():

Yes, this is very inefficient which is one of the reasons I don't use  
the generic file write helpers in NTFS.  The other reasons are that  
supporting larger logical block sizes than PAGE_CACHE_SIZE becomes a  
pain if it is not done this way when the write targets a hole as that  
requires all pages in the hole to be locked simultaneously which  
would mean dropping the page lock to acquire the others that are of  
lower page index and to then re-take the page lock which is horrible  
- much better to lock all at once from the outset and the other  
reason is that in NTFS there is such a thing as the initialized size  
of an attribute which basically states "anything past this byte  
offset must be returned as 0 on read, i.e. it does not have to be  
read from disk at all, and on write beyond the initialized_size you  
have to zero on disk everything between the old initialized size and  
the start of the write before you begin writing and certainly before  
you update the initalized_size otherwise a concurrent read would see  
random old data from the disk.

For NTFS this effectively becomes:

> sys_write(file, buffer, 1MB)

allocate space for the entire 1MB write

if write offset past the initialized_size zero out on disk starting  
at initialized_size up to the start offset for the write and update  
the initialized size to be equal to the start offset of the write

do {
	if (current position is in a hole and the NTFS logical block size is  
 > PAGE_CACHE_SIZE) {
		work on (NTFS logical block size / PAGE_CACHE_SIZE) pages in one go;
		do_pages = vol->cluster_size / PAGE_CACHE_SIZE;
	} else {
		work on only one page;
		do_pages = 1;
	}
	fault in for read (do_pages*PAGE_CACHE_SIZE) bytes worth of source  
pages
	grab do_pages worth of pages
	prepare_write - attach buffers to grabbed pages
	copy data from source to grabbed&prepared pages
	commit_write the copied pages by dirtying their buffers
} while (data left to write);

The allocation in advance is a huge win both in terms of avoiding  
fragmentation (NTFS still uses a very simple/stupid allocator so you  
get a lot of fragmentation if two processes write to different files  
simultaneously and do so in small chunks) and in terms of performance.

I have wondered whether I should perhaps turn on the "multi page"  
stuff on for all writes rather than just for ones that go into a hole  
and the logical size is greater than the PAGE_CACHE_SIZE as that  
might improve performance even further but I haven't had the time/ 
inclination to experiment...

And I have also wondered whether to go direct to bio/wholes pages at  
once instead of bothering with dirtying each buffer but the buffers  
(which are always 512 bytes on NTFS) allow me to easily support  
dirtying smaller parts of the page which is desired at least on  
volumes with a logical block size < PAGE_CACHE_SIZE as different bits  
of the page could then reside on completely different locations on  
disk so writing out unneeded bits of the page could result in a lot  
of wasted disk head seek times.

Best regards,

	Anton

> for each page:
>     prepare_write()
> 	allocate contiguous chunks of disk
>         attach buffers
>     copy_from_user()
>     commit_write()
>         dirty buffers
>
> pdflush:
>     writepages()
>         find pages with contiguous chunks of disk
> 	build and submit large bios
>
> So, we replace prepare_write and commit_write with an extent based  
> api,
> but we keep the dirty each buffer part.  writepages has to turn that
> back into extents (bio sized), and the result is completely full of  
> dark
> dark corner cases.
>
> I do think fsblocks is a nice cleanup on its own, but Dave has a good
> point that it makes sense to look for ways generalize things even  
> more.
>
> -chris

-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
