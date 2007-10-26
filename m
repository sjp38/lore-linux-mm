From: Neil Brown <neilb@suse.de>
Date: Fri, 26 Oct 2007 12:00:45 +1000
Message-ID: <18209.19021.383347.160126@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: message from Hugh Dickins on Thursday October 25
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
	<200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
	<84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
	<Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
	<84144f020710221348x297795c0qda61046ec69a7178@mail.gmail.com>
	<Pine.LNX.4.64.0710251556300.1521@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday October 25, hugh@veritas.com wrote:
> On Mon, 22 Oct 2007, Pekka Enberg wrote:
> > On 10/22/07, Hugh Dickins <hugh@veritas.com> wrote:
> > > Only ramdisk and shmem have been returning AOP_WRITEPAGE_ACTIVATE.
> > > Both of those set BDI_CAP_NO_WRITEBACK.  ramdisk never returned it
> > > if !wbc->for_reclaim.  I contend that shmem shouldn't either: it's
> > > a special code to get the LRU rotation right, not useful elsewhere.
> > > Though Documentation/filesystems/vfs.txt does imply wider use.
> > >
> > > I think this is where people use the phrase "go figure" ;)
> > 
> > Heh. As far as I can tell, the implication of "wider use" was added by
> > Neil in commit "341546f5ad6fce584531f744853a5807a140f2a9 Update some
> > VFS documentation", so perhaps he might know? Neil?

I just read the code, tried to understand it, translated that
understanding into English, and put that in vfs.txt.
It is very possible that what I wrote didn't match the intention of
the author, but it seemed to match the behaviour of the code.

The patch looks like it makes perfect sense to me.
Before the change, ->writepage could return AOP_WRITEPAGE_ACTIVATE
without unlocking the page, and this has precisely the effect of:
   ClearPageReclaim();  (if the call path was through pageout)
   SetPageActive();  (if the call was through shrink_page_list)
   unlock_page();

With the patch, the ->writepage method does the SetPageActive and the
unlock_page, which on the whole seems cleaner.

We seem to have lost a call to ClearPageReclaim - I don't know if that
is significant.

> 
> Special, hidden, undocumented, secret hack!  Then in 2.6.7 Andrew
> stole his own secret and used it when concocting ramdisk_writepage.
> Oh, and NFS made some kind of use of it in 2.6.6 only.  Then Neil
> revealed the secret to the uninitiated in 2.6.17: now, what's the
> appropriate punishment for that?

Surely the punishment should be for writing hidden undocumented hacks
in the first place!  I vote we just make him maintainer for the whole
kernel - that will keep him so busy that he will never have a chance
to do it again :-)

> --- 2.6.24-rc1/Documentation/filesystems/vfs.txt	2007-10-24 07:15:11.000000000 +0100
> +++ linux/Documentation/filesystems/vfs.txt	2007-10-24 08:42:07.000000000 +0100
> @@ -567,9 +567,7 @@ struct address_space_operations {
>        If wbc->sync_mode is WB_SYNC_NONE, ->writepage doesn't have to
>        try too hard if there are problems, and may choose to write out
>        other pages from the mapping if that is easier (e.g. due to
> -      internal dependencies).  If it chooses not to start writeout, it
> -      should return AOP_WRITEPAGE_ACTIVATE so that the VM will not keep
> -      calling ->writepage on that page.
> +      internal dependencies).
>  

It seems that the new requirement is that if the address_space
chooses not to write out the page, it should now call SetPageActive().
If that is the case, I think it should be explicit in the
documentation - please?

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
