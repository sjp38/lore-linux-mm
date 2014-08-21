Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2937B6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 05:48:01 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so8935381wev.26
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 02:48:00 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id h1si6572214wje.54.2014.08.21.02.47.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 02:47:59 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so8853642wgh.18
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 02:47:59 -0700 (PDT)
Message-ID: <53F5C04B.5000900@gmail.com>
Date: Thu, 21 Aug 2014 12:47:55 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/9] SQUASHME: prd: Fixs to getgeo
References: <53EB5536.8020702@gmail.com> <53EB568B.2060006@plexistor.com> <1408572624.26863.17.camel@rzwisler-mobl1.amr.corp.intel.com>
In-Reply-To: <1408572624.26863.17.camel@rzwisler-mobl1.amr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Boaz Harrosh <boaz@plexistor.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/21/2014 01:10 AM, Ross Zwisler wrote:
> On Wed, 2014-08-13 at 15:14 +0300, Boaz Harrosh wrote:
<>
>>  static int prd_getgeo(struct block_device *bd, struct hd_geometry *geo)
>>  {
>> -	/* some standard values */
>> -	geo->heads = 1 << 6;
>> -	geo->sectors = 1 << 5;
>> -	geo->cylinders = get_capacity(bd->bd_disk) >> 11;
>> +	/* Just tell fdisk to get out of the way. The math here is so
>> +	 * convoluted and does not make any sense at all. With all 1s
>> +	 * The math just gets out of the way.
>> +	 * NOTE: I was trying to get some values that will make fdisk
>> +	 * Want to align first sector on 4K (like 8, 16, 20, ... sectors) but
>> +	 * nothing worked, I searched the net the math is not your regular
>> +	 * simple multiplication at all. If you managed to get these please
>> +	 * fix here. For now we use 4k physical sectors for this
>> +	 */
>> +	geo->heads = 1;
>> +	geo->sectors = 1;
>> +	geo->cylinders = 1;
>>  	return 0;
>>  }
> 
> I'm okay with this change, but can you let me know in which case fdisk was
> previously doing the wrong thing?  I'm just curious because I never saw it
> misbehave, and wonder what else I should be testing.
> 

OK fdisk was doing a a few wrong things for us, this one here fixes one of
them.

Ways to reproduce
You need to have a small enough device, how small I do not know, but with
a 1G device fdisk will offer a 2048 first sectors [1M] always, so with big
devices you will not see this.

But with small devices without this patch fdisk will offer I can't remember
I think it was 18 originally (note the not 4K alignment) and 20 with my
other 4k-phisical patch.
With this one applied it will give me 8 as possible first sector.

What fdisk does is takes bunch of stuff into consideration and uses the
maximum as its base alignment. Then it has more code about the very
first sector that needs to be aligned on the alignment factor but has more
considerations like device size and stuff I guess it wants 1M at start of
disk to leave space for a boot sector.

I would love it if for brd and pmem fdisk will always offer 8, I intend to
send a patch to fdisk to fix that.

But regarding the above, with high values here we can get higher first sector
and funny alignments, with all 1(s) this math gets out of the way.

> Regarding the note in the comment, is this addressed by the
> blk_queue_physical_block_size() and prd->prd_queue->limits.io_min changes in
> your patch 5/9, or is it an open issue?  Either way, can we nix the NOTE?
> 

Yes  5/9 set-physical-sector to 4k fixes this problem and with that
fdisk will not offer the wrong numbers

What you mean nix, get rid of it? We should say something. I will try to
shorten it to a single paragraph, let me send you a fix.

> Also, you put "SQUASHME" on this patch.  I'm planning on squashing all of my
> patches together into an "initial version" type patch (see
> https://github.com/01org/prd).  Based on this, it probably makes sense to keep
> it separate so you get credit for the patch?
> 

The initial version did not include the getgeo patch and the rw_page patch.
I think it makes sense to keep pmem as a small patchset for submission, basic
functionality, then added optional API, one by one. It is easier for review and
stages things nicely. For me I have this list here:

a2cd031 Yigal Korman            |  (HEAD, prd) prd: Add support for page struct mapping 
5f3d00e Yigal Korman            |  mm: export sparse_add/remove_one_section 
5bdf5f7 Boaz Harrosh            |  pmem: Add getgeo to block ops 
387daf9 Ross Zwisler            |  pmem: add support for rw_page() 
5629da1 Ross Zwisler            |  pmem: Initial version of Persistent RAM Driver 

The first patch, Initial version will need to have both our sign-off and
a note about a tree with full history at the github address. I've been
participating in the pnfs tree where we worked like that for 4 years with
100ds of patches.

The one thing you must not do is delete the old trees. at first you make a branch
with the SQUASHMES as is, then rebase do the squashes and produce a new clean branch.
Tag them. Farther development gets as SQUASHMEs on top, tagged rebased and so on.
Then final upstream submission notes of the public tree that has the real history.
That's the process we worked with the big companies lawyers.
Note that anyone that touched a part of any patch, will need to have his sign-off
on it, then authorship is arbitrated by content.

> - Ross
> 


Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
