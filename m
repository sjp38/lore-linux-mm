Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B99B86B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 14:42:58 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p44IguhD027351
	for <linux-mm@kvack.org>; Wed, 4 May 2011 11:42:56 -0700
Received: from gya6 (gya6.prod.google.com [10.243.49.6])
	by hpaq5.eem.corp.google.com with ESMTP id p44IgsZ5024285
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 11:42:55 -0700
Received: by gya6 with SMTP id 6so680242gya.21
        for <linux-mm@kvack.org>; Wed, 04 May 2011 11:42:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110504094930.GA30358@lst.de>
References: <201105032057.p43Kvj4C009848@imap1.linux-foundation.org>
	<20110504094930.GA30358@lst.de>
Date: Wed, 4 May 2011 11:42:53 -0700
Message-ID: <BANLkTi=bfpOyCPPZBj8QkDzUPeRf=Cfcqg@mail.gmail.com>
Subject: Re: + writeback-split-inode_wb_list_lock-into-bdi_writebacklist_lock-fix-f
 ix.patch added to -mm tree
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, May 4, 2011 at 2:49 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Tue, May 03, 2011 at 01:57:44PM -0700, akpm@linux-foundation.org wrote=
:
>> =C2=A0 =C2=A0 =C2=A0 struct backing_dev_info *old =3D inode->i_data.back=
ing_dev_info;
>>
>> - =C2=A0 =C2=A0 if (dst =3D=3D old)
>> + =C2=A0 =C2=A0 if (dst =3D=3D old) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 /* deadlock avoidance */
>
> That's not an overly useful comment. =C2=A0It should be a proper block co=
ment
> documentation how that we could ever end up with the same bdi as
> destination and source.

I didn't put in a comment myself because it seemed obvious that we'd
want to avoid calling something named bdi_lock_two(a, b) when a and b
are the same; and I was expecting it to be obvious to you that
actually we could get here with a and b the same.  But apparently not.
 default_backing_dev_info?

>
> Which is something I wanted to ask Hugh anyway - do you have traces expla=
ining
> how this happens for you?

Let's take out the patch and jot down the dmesg, omitting ? stale
lines and function offsets from the backtrace.

Something that may prove relevant: this is openSUSE 11.4, which cannot
boot my kernels unless I have CONFIG_DEVTMPFS=3Dy; and I've set
CONFIG_DEVTMPFS_MOUNT=3Dy too.  No initramfs.

...
VFS: Mounted root (ext2 filesystem) readonly on device 8:1.
devtmpfs: mounted
Freeing unused kernel memory: 352k freed
udev[162]: starting version 166
BUG: spinlock recursion on CPU#0, blkid/299
lock: 78690c30, .magic: dead4ead, .owner: blkid/299, .owner_cpu: 0
Pid: 299, comm: blkid Not tainted 2.6.39-rc5-mm1 #4
Call Trace:
spin_bug
do_raw_spin_lock
_raw_spin_lock_nested
bdi_lock_two
bdev_inode_switch_bdi
__blkdev_get
blkdev_get
blkdev_open
__dentry_open
nameidata_to_filp
do_last
path_openat
do_filp_open
do_sys_open
sys_open
sysenter_do_call

And indeed that "lock: 78690c30" falls inside my
default_backing_dev_info at 78690ae4.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
