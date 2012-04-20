Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id E54996B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:42:13 -0400 (EDT)
Message-ID: <1334932928.13001.11.camel@dabdike>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 20 Apr 2012 18:42:08 +0400
In-Reply-To: <alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>
	  <4F912880.70708@panasas.com>
	  <alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
	 <1334919662.5879.23.camel@dabdike>
	 <alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On Fri, 2012-04-20 at 13:23 +0200, Lukas Czerner wrote:
> On Fri, 20 Apr 2012, James Bottomley wrote:
> 
> > On Fri, 2012-04-20 at 11:45 +0200, Lukas Czerner wrote:
> > > On Fri, 20 Apr 2012, Boaz Harrosh wrote:
> > > 
> > > > On 04/19/2012 10:20 PM, Theodore Ts'o wrote:
> > > > 
> > > > > As I had brought up during one of the lightning talks at the Linux
> > > > > Storage and Filesystem workshop, I am interested in introducing two new
> > > > > open flags, O_HOT and O_COLD.  These flags are passed down to the
> > > > > individual file system's inode operations' create function, and the file
> > > > > system can use these flags as a hint regarding whether the file is
> > > > > likely to be accessed frequently or not.
> > > > > 
> > > > > In the future I plan to do further work on how ext4 would use these
> > > > > flags, but I want to first get the ability to pass these flags plumbed
> > > > > into the VFS layer and the code points for O_HOT and O_COLD reserved.
> > > > > 
> > > > > 
> > > > > Theodore Ts'o (3):
> > > > >   fs: add new open flags O_HOT and O_COLD
> > > > >   fs: propagate the open_flags structure down to the low-level fs's
> > > > >     create()
> > > > >   ext4: use the O_HOT and O_COLD open flags to influence inode
> > > > >     allocation
> > > > > 
> > > > 
> > > > 
> > > > I would expect that the first, and most important patch to this
> > > > set would be the man page which would define the new API. 
> > > > What do you mean by cold/normal/hot? what is expected if supported?
> > > > how can we know if supported? ....
> > > 
> > > Well, this is exactly my concern as well. There is no way anyone would
> > > know what it actually means a what users can expect form using it. The
> > > result of this is very simple, everyone will just use O_HOT for
> > > everything (if they will use it at all).
> > > 
> > > Ted, as I've mentioned on LSF I think that the HOT/COLD name is really
> > > bad choice for exactly this reason. It means nothing. If you want to use
> > > this flag to place the inode on the faster part of the disk, then just
> > > say so and name the flag accordingly, this way everyone can use it.
> > > However for this to actually work we need some fs<->storage interface to
> > > query storage layout, which actually should not be that hard to do. I am
> > > afraid that in current form it will suit only Google and Taobao. I would
> > > really like to have interface to pass tags between user->fs and
> > > fs<->storage, but this one does not seem like a good start.
> > 
> > I think this is a little unfair.  We already have the notion of hot and
> > cold pages within the page cache.  The definitions for storage is
> > similar: a hot block is one which will likely be read again shortly and
> > a cold block is one that likely won't (ignoring the 30 odd gradations of
> > in-between that the draft standard currently mandates)
> 
> You're right, but there is a crucial difference, you can not compare
> a page with a file. Page will be read or .. well not read so often, but
> that's just one dimension. Files has a lot more dimensions, will it be
> rewritten often ? will it be read often, appended often, do we need
> really fast first access ? do we need fast metadata operation ? Will
> this file be there forever, or is it just temporary ? Do we need fast
> read/write ? and many more...

Yes and no.  I agree with your assessment.  The major point you could
ding me on actually is that just because a file is hot doesn't mean all
its pages are it could only have a few hot pages in it.  You could also
argue that the time scale over which the page cache considers a page hot
and that over which a disk does the same might be so dissimilar as to
render the two usages orthogonal.

The points about read and write are valid, but we could extend the page
cache to them too.  For instance, our readahead decisions are done at a
bit of the wrong level (statically in block).  If the page cache knew a
file was streaming (a movie file, for instance), we could adjust the
readahead dynamically for that file.

Where this might be leading is that the file/filesystem hints to the
page cache, and the page cache hints to the device.  That way, we could
cope with the hot file with only a few hot pages case.

The drawback is that we really don't have much of this machinery in the
page cache at the moment, and it's questionable if we really want it.
Solving our readahead problem would be brilliant, especially if the
interface were hintable, but not necessarily if it involves huge
algorithmic expense in our current page cache.

> > The concern I have is that the notion of hot and cold files *isn't*
> > propagated to the page cache, it's just shared between the fs and the
> > disk.  It looks like we could tie the notion of file opened with O_HOT
> > or O_COLD into the page reclaimers and actually call
> > free_hot_cold_page() with the correct flag, meaning we might get an
> > immediate benefit even in the absence of hint supporting disks.
> 
> And this is actually very good idea, but the file flag should not be
> O_HOT/O_COLD (and in this case being it open flag is really disputable
> as well), but rather hold-this-file-in-memory-longer-than-others, or
> will-read-this-file-quite-often. Moreover since with Ted's patches O_HOT
> means put the file on faster part of the disk (or rather whatever fs
> thinks is fast part of the disk, since the interface to get such
> information is missing) we already have one "meaning" and with this
> we'll add yet another, completely different meaning to the single
> flag. That seems messy.

I'm not at all wedded to O_HOT and O_COLD; I think if we establish a
hint hierarchy file->page cache->device then we should, of course,
choose the best API and naming scheme for file->page cache.  The only
real point I was making is that we should tie in the page cache, and
currently it only knows about "hot" and "cold" pages.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
