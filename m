Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id CD1AA6B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 07:23:04 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so170965eak.25
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 04:23:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si88539839eei.81.2014.01.07.04.23.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 04:23:03 -0800 (PST)
Date: Tue, 7 Jan 2014 13:23:01 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
Message-ID: <20140107122301.GC16640@quack.suse.cz>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue 07-01-14 16:04:03, Saket Sinha wrote:
> I would like to attend LSF/MM summit. I will like to discuss approach
> to be taken to finally bring up a Union Filesystem for Linux kernel.
> 
> My tryst with Union Filesystem began when I was involved developing a
> filesystem as a part of  GSOC2013(Google Summer of Code) for CERN
> called Hepunion Filesystem.
> 
> CERN needs a union filesystem for LHCb to provide fast diskless
> booting for its nodes. For such an implementation, they need a file
> system with two branches a Read-Write and a Read Only so they decided
> to write a completely new union file system called Hepunion. The
> driver was  partially completed and worked somewhat with some issues
> on 2.6.18. since they were using SCL5(Scientific Linux),
> 
> Now since LHCb is  moving to newer kernels, we ported it to newer
> kernels but this is where the problem started. The design of our
> filesystem was this that we used "path" to map the VFS and the lower
> filesystems. With the addition of RCU-lookup in 2.6.35, a lot of
> locking was added  in kernel functions like kern_path and made our
> driver unstable beyond repair.
> 
> So now we are redesigning the entire thing from scratch.
> 
> We want to develop this Filesystem to finally have a stackable union
> filesystem for the mainline Linux kernel . For such an effort,
> collaborative development and community support is a must.
> 
> 
> For the redesign, AFAIK
> I can think of two ways to do it-
> 
>  1. VFS-based stacking solution- I would like to cite the work done by
> Valerie Aurora was closest.
> 
>  2. Non-VFS-based stacking solution -  UnionFS, Aufs and the new Overlay FS
  So I'm wondering, have you tried using any of the above mentioned
solutions? I know at least Overlay FS should be pretty usable with any
recent kernel, aufs seems to be ported to recent kernels as well. I'm not
sure how recent patches can you get for unionfs. Are you missing some
functionality?

> Patches for kernel exists for overlayfs & unionfs.
> What is communities view like which one would be good fit to go with?
  Currently Miklos Szeredi is working on getting his Overlay FS upstream,
also UnionFS has reasonable chance of getting there eventually. Currently
both of them are blocked by some VFS changes AFAIK and Miklos is working on
them.

> The use case that I am looking from the stackable filesystem is  that
> of "diskless node handling" (for CERN where it is required to provide
> a faster diskless
> booting to the Large Hadron Collider Beauty nodes).
> 
>  For this we need a
> 1. A global Read Only FIlesystem
> 2. A client-specific Read Write FIlesystem via NFS
> 3. A local Merged(of the above two) Read Write FIlesystem on ramdisk.
  I'm not sure I understand. So you have one read-only FS which is exported
to cliens over NFS I presume. Then you have another client specific
filesystem, again mounted over NFS. I'm somewhat puzzled by the
'read-write' note there - do you mean that the client-specific filesystem
can be changed while it is mounted by a client? Or do you mean that the
client can change the filesystem to store its data? And if client can store
data on NFS, what is the purpose of a filesystem on ramdisk?

> Thus to design such a fileystem I need community support and hence
> want to attend LSF/MM summit.
  So my suggestion would be to try OverlayFS / UnionFS, see what works /
doesn't work for you and work with respective developers to address your
needs. We definitely don't need yet another fs-unioning implementation.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
