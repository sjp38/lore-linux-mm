Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7985E6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 06:16:44 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so602808eek.26
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 03:16:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si92947391eem.40.2014.01.08.03.16.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 03:16:43 -0800 (PST)
Date: Wed, 8 Jan 2014 12:16:40 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
Message-ID: <20140108111640.GD8256@quack.suse.cz>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
 <20140107122301.GC16640@quack.suse.cz>
 <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Wed 08-01-14 01:34:47, Saket Sinha wrote:
> >   So I'm wondering, have you tried using any of the above mentioned
> > solutions? I know at least Overlay FS should be pretty usable with any
> > recent kernel, aufs seems to be ported to recent kernels as well. I'm not
> > sure how recent patches can you get for unionfs.
> >
> 
> Several implementations of union file system fusion were evaluated.
> The results of the evaluation is shown at the below link-
> http://www.4shared.com/download/7IgHqn4tce/1_online.png
> 
> While evaluating union file systems implementations, it became clear
> that none was perfect for net booted nodes.
> All were designed with totally different goals than ours.
> 
> One of the big problems was that too many copyups were made on the
> read-write file system. So we decided to implement an union file
> system designed for diskless systems, with the following
> functionalities:
> 
> 1. union between only one read-only and one read-write file systems
> 
> 2. if only the file metadata are modified, then do not
> copy the whole file on the read-write files system but
> only the metadata (stored with a file named as the file
> itself prefixed by '.me.')
  So do you do anything special at CERN so that metadata is often modified
without data being changed? Because there are only two operations where I
can imagine this to be useful:
1) atime update - but you better turn atime off for unioned filesystem
   anyway.
2) xattr update

> 3. check when files on the read-write file system can be removed
  How can that happen?

> >Are you missing some  functionality?
> 
> The use case of a union type filesystem that I am looking for (CERN)
> is diskless clients which AFAIR this can not be done in overlayfs.
> Correct me if I am wrong.
  Well, I believe all unioning solutions want to support the read-only
filesystem overlayed by a read-write filesystem. Your points 2. and 3. is
what makes your requirements non-standard.

> >>  For this we need a
> >> 1. A global Read Only FIlesystem
> >> 2. A client-specific Read Write FIlesystem via NFS
> >> 3. A local Merged(of the above two) Read Write FIlesystem on ramdisk.
> >   I'm not sure I understand.
> 
> Let me answer question one by one to explain
> >So you have one read-only FS which is exported  to cliens over NFS I presume. Then you have another client specific
> > filesystem, again mounted over NFS.
> We first tried to make the union on the nodes during diskless
> initialisation but finally choose to do it on the
> server, and NFS exports the a??unioneda?? file system. Client side union
> was just using too much memory.
> 
> >I'm somewhat puzzled by the  'read-write' note there - do you mean that the client-specific filesystem
> > can be changed while it is mounted by a client? Or do you mean that the
> > client can change the filesystem to store its data?
> I mean the client has the permission to change the data and modify it.
> 
> 
>  >And if client can store
> > data on NFS, what is the purpose of a filesystem on ramdisk?
> 
> I am sorry for that I wanted to give that as an alternative to the
> above approach. Just a typo.
> A local Merged(of the above two) Read Write FIlesystem on ramdisk is
> something what happens in Knoppix distro where you get an impression
> that you are able to change and modify data.
  OK, that makes sense now. Thanks for explanation.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
