Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A33406B0127
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 13:34:29 -0400 (EDT)
Date: Thu, 4 Oct 2012 13:34:25 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Repeatable ext4 oops with 3.6.0 (regression)
Message-ID: <20121004173425.GA15405@thunk.org>
References: <pan.2012.10.02.11.19.55.793436@googlemail.com>
 <20121002133642.GD22777@quack.suse.cz>
 <pan.2012.10.02.14.31.57.530230@googlemail.com>
 <20121004130119.GH4641@quack.suse.cz>
 <506DABDD.7090105@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <506DABDD.7090105@googlemail.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Holger =?iso-8859-1?Q?Hoffst=E4tte?= <holger.hoffstaette@googlemail.com>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 04, 2012 at 05:31:41PM +0200, Holger Hoffst=E4tte wrote:

> So armed with multiple running shells I finally managed to save the dme=
sg
> to NFS. It doesn't get any more complete than this and again shows the
> ext4 stacktrace from before. So maybe it really is generic kmem corrupt=
ion
> and ext4 looking at symlinks/inodes is just the victim.

That certainly seems to be the case.  As near as I can tell from the
stack trace, you're doing a readdir(), and the crash is happening in
ext4_htree_store_dirent() --- the stack address to ext4_follow_link()
makes no sense given the rest of the strack trace, and anyway,
ext4_follow_link() doesn't do any memory allocation.

So that means this:
> [  106.643048]  [<c0236ed9>] ext4_htree_store_dirent+0x29/0x110

Almost certainly corresponds to the following call to kzalloc:

	/* Create and allocate the fname structure */
	len =3D sizeof(struct fname) + dirent->name_len + 1;
	new_fn =3D kzalloc(len, GFP_KERNEL);

dirent->name_len is a unsigned char, and struct fname is around 48
bytes or so.  So len is never going to be larger than 300 bytes, and
never smaller than 48 bytes, which is certainly valid input as far as
kzalloc() is concerned.

So it's very likely that the crash in __kmalloc() is probably caused
by the internal slab/slub data structures getting scrambled.

Regards,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
