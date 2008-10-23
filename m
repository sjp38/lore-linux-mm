Date: Thu, 23 Oct 2008 10:44:16 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081023094416.GA6640@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org> <20081022103112.GA27862@wotan.suse.de> <20081022230715.GX18495@disturbed> <20081023070711.GB30765@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081023070711.GB30765@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Oct 23, 2008 at 09:07:11AM +0200, Nick Piggin wrote:
> On Thu, Oct 23, 2008 at 10:07:15AM +1100, Dave Chinner wrote:
[snip]
> 
> > You could do the same thing for metadata read operations. e.g. build
> > a large directory structure, then do read operations on it (readdir,
> > stat, etc) and inject errors into each of those. All filesystems
> > should return the (EIO) error to the application in this case.
> > 
> > Those two cases should be pretty generic and deterministic - they
> > both avoid the difficult problem of determining what the response
> > to an I/O error during metadata modifcation should be....
> 
> Good suggestion.
> 
> I'll see what I can do. I'm using the fault injection stuff, which I
> don't think can distinguish metadata, so I might just have to work
> out a bio flag or something we can send down to the block layer to
> distinguish.
> 
> Thanks,
> Nick
>

Don't we already have such a flag? I know that its not set in all
the correct places in GFS2 so far, but I've gradually been fixing
them to include BIO_RW_META where appropriate.

Also it occurs to me that we can use FIEMAP to discover where a
parciular file is and that would then allow us to target error
injection at particular blocks of the file.

Given that we can cover xattr blocks with FIEMAP too[*], and that at
least with GFS2 and similar filesystems the inode number is the
block number of the inode, the only thing that would be missing,
in terms of locating inode data & metadata would be the indirect blocks,

Steve.

[*] GFS2's FIEMAP doesn't support xattrs yet, but its on my todo list

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
