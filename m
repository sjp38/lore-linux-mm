From: Christoph Rohland <cr@sap.com>
Subject: Re: shmfs/tmpfs/vm-fs
References: <01120616545301.04747@hishmoom> <m34rn3jobk.fsf@linux.local>
	<01120712372904.00795@hishmoom> <m3vgfjjcfz.fsf@linux.local>
	<3C11B5A4.1070708@zytor.com>
Message-ID: <m38zcejc65.fsf@linux.local>
Date: 08 Dec 2001 10:54:05 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: lothar.maerkle@gmx.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi hpa,

On Fri, 07 Dec 2001, H. Peter Anvin wrote:
> Christoph Rohland wrote:
> 
>> It was possible in some 2.3 kernels, but this had to be removed
>> with the cleanup :-(
> 
> I guess I really still don't understand why.  

It is mainly a matter of simplicity: Filesystem semantics differ
considerably from the SYSV semantics and I can assure you that the old
implementation was a nightmare to maintain and keep compatible with
all the little oddities of SYSV shm.

E.g. there is a creator id which you cannot change and
which is always allowed to control the opject. Also the Linux feature,
that you can SHM_RMID a segment but still access is with its id as
long as there are references is pretty unusual for filesystems.

So I had to realise that the SYSV shm API does _not_ correspond to
files in a directory, but it more an open struct file without a linked
directory entry. This struct file is managed by the SYSV ipc module
and the user can access it via shmat. This model works out quite
naturally.

The whole interface between ipc/shm.c and mm/shmem.c is
shmem_file_setup, shmem_nopage and shmem_lock!  shmem does not know
anything about SYSV and its weird semantics.

> I certainly can understand that it would be highly undesirable if it
> had to be supported before /dev/shm is mounted, but I don't see any
> reason to allow SysV shared memory before mounting /dev/shm.

I would like this behaviour as well, but it would mean to complicate
the whole thing more than it's worth.

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
