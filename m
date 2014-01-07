Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5247A6B0036
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 15:04:49 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id mx13so390976bkb.32
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 12:04:48 -0800 (PST)
Received: from mail-bk0-x236.google.com (mail-bk0-x236.google.com [2a00:1450:4008:c01::236])
        by mx.google.com with ESMTPS id lu3si24475609bkb.214.2014.01.07.12.04.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 12:04:48 -0800 (PST)
Received: by mail-bk0-f54.google.com with SMTP id v16so387781bkz.41
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 12:04:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140107122301.GC16640@quack.suse.cz>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
	<20140107122301.GC16640@quack.suse.cz>
Date: Wed, 8 Jan 2014 01:34:47 +0530
Message-ID: <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

>   So I'm wondering, have you tried using any of the above mentioned
> solutions? I know at least Overlay FS should be pretty usable with any
> recent kernel, aufs seems to be ported to recent kernels as well. I'm not
> sure how recent patches can you get for unionfs.
>

Several implementations of union file system fusion were evaluated.
The results of the evaluation is shown at the below link-
http://www.4shared.com/download/7IgHqn4tce/1_online.png

While evaluating union file systems implementations, it became clear
that none was perfect for net booted nodes.
All were designed with totally different goals than ours.

One of the big problems was that too many copyups were made on the
read-write file system. So we decided to implement an union file
system designed for diskless systems, with the following
functionalities:

1. union between only one read-only and one read-write file systems

2. if only the file metadata are modified, then do not
copy the whole file on the read-write files system but
only the metadata (stored with a file named as the file
itself prefixed by '.me.')

3. check when files on the read-write file system can be removed

>Are you missing some  functionality?

The use case of a union type filesystem that I am looking for (CERN)
is diskless clients which AFAIR this can not be done in overlayfs.
Correct me if I am wrong.

>> Patches for kernel exists for overlayfs & unionfs.
>> What is communities view like which one would be good fit to go with?
>   Currently Miklos Szeredi is working on getting his Overlay FS upstream,
> also UnionFS has reasonable chance of getting there eventually. Currently
> both of them are blocked by some VFS changes AFAIK and Miklos is working =
on
> them.
>
This is what I am looking forward too. I want to know what all exactly
kernel maintainers want from a stackable Union filesystem which they
finally would let into mainline kernel. I even wrote to Al-Viro and
linux-fsdevel community but haven't got any responses. UnionFS and
Aufs have existed for many years outside the mainline kernel with no
signs of ever get included. Recently I have heard a lot about Overlay
Fs too but I even doubt its fate.


>>  For this we need a
>> 1. A global Read Only FIlesystem
>> 2. A client-specific Read Write FIlesystem via NFS
>> 3. A local Merged(of the above two) Read Write FIlesystem on ramdisk.
>   I'm not sure I understand.

Let me answer question one by one to explain
>So you have one read-only FS which is exported  to cliens over NFS I presu=
me. Then you have another client specific
> filesystem, again mounted over NFS.
We first tried to make the union on the nodes during diskless
initialisation but finally choose to do it on the
server, and NFS exports the =93unioned=94 file system. Client side union
was just using too much memory.

>I'm somewhat puzzled by the  'read-write' note there - do you mean that th=
e client-specific filesystem
> can be changed while it is mounted by a client? Or do you mean that the
> client can change the filesystem to store its data?
I mean the client has the permission to change the data and modify it.


 >And if client can store
> data on NFS, what is the purpose of a filesystem on ramdisk?

I am sorry for that I wanted to give that as an alternative to the
above approach. Just a typo.
A local Merged(of the above two) Read Write FIlesystem on ramdisk is
something what happens in Knoppix distro where you get an impression
that you are able to change and modify data.

Let me list the RHEL way of setting up a diskless server for perhaps
better understanding.
Up to RHEL5, Red Hat had a package named systemconfig-netboot to setup
diskless servers. It was a set of
python and bash scripts that were setting up the dhcpd and tftpd
servers, customising the shared root file system
and making the initial ramdisk for the diskless nodes.

To make some files of the root file system writeable for the nodes,
with possibly different contents, the
initialisation script from this package was making the following
actions after having mounted the root file
system:
=95 Mount the 'snapshot' directory from the server, in read/write mode.
This directory contains one subdirectory
per node and two files with the list of the files that need to be writable.
=95 Remount (using the bind mount option) each of these files from the
node's snapshot to the root file system.

There are two problems with this method:
=95 Only files or folders of the fixed list can be writeable. To add a
file to that list, we have to reboot the nodes
after the file list modification.
=95 The mount table is 'polluted' by all these remounts.

Our solution: To add flexibility to the diskless nodes handling, we
had the idea of using file system union

>> Thus to design such a fileystem I need community support and hence
>> want to attend LSF/MM summit.
>   So my suggestion would be to try OverlayFS / UnionFS, see what works /
> doesn't work for you and work with respective developers to address your
> needs. We definitely don't need yet another fs-unioning implementation.
>
I am sorry but as all the existing solutions do not completely meet my
use-case mentioned above. Even I do not want to re-invent the wheel
but  I have mentioned above the reasons why we went for a new
solution.

Regards,
Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
