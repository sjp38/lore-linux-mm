Date: Tue, 11 Jan 2000 12:18:11 +0100 (MET)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem
In-Reply-To: <nn66x1wtgh.fsf@code.and.org>
Message-ID: <Pine.LNX.4.10.10001111217130.23008-100000@linux16.zdv.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Antill <james@and.org>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Andi Kleen <ak@muc.de>, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Oh no! Not another /proc. Please do a different fs, perhaps you can
share some code with shmfs, but not the namespace!

Richard.

On 10 Jan 2000, James Antill wrote:
> > Andi Kleen <ak@muc.de> writes:
> > > On Mon, Jan 10, 2000 at 01:20:40PM +0100, Christoph Rohland wrote:
> > > > Hi folks,
> > > > 
> > > > This patch implements a minimal filesystem for shared memory. It
> > > > replaces/reuses the existing SYSV shm code so you now have to mount
> > > > the fs to be able to use SYSV SHM. But in turn we now have everything
> > > > in place to implement posix shm. This also obsoletes vm_private_data
> > > > in vm_area_struct.
> > > 
> > > I planed to map the Unix Sockets abstract name space to a file system
> > > for some time now.  Because it would be silly to write another file
> > > system just for that rather obscure feature, would it be possible
> > > to use a subdirectory in your new shm filesystem? I haven't looked
> > > at the code at all yet, and don't know if it can even deal with 
> > > directories and special devices. Do you have objections to such 
> > > a direction?
> > 
> > In the current state this is not possible. The shm fs does not support
> > directories and only regular files (which you can only mmap, no
> > read/write support).
> > 
> > But we could later extend the fs to support directories and special
> > files. The Unix Sockets could probably also use the same mechanisms
> > for locating the special fs like SYSV ipc does.
> > 
> > With these changes we also should then be able to mount the fs several
> > times. So we also get the chroot case fixed.
> 
>  If the idea is to integrate the unix domain sockets at some point,
> then I'd like to suggest that _both_ shm and unix domain sockets get a
> subtree. Ie.
> 
> /kernfs/unix_domain_sockets/*
> /kernfs/sysv_shared_memory/*
> 
>  Instead of...
> 
> /shm/unix_domain_sockets/*
> /shm/* (apart from unix_domain_sockets, and maybe others)
> 
>  Obviously example names might be too long for your tastes.
> 
>  This also makes it easier to add new directories (don't say it won't
> happen look at proc :).
> 
>  Indeed a possibly useful one that I can think of straight away is...
> 
> /kernfs/users/<uid>/
> 
>  Where it could store entries to inodes that no longer have a file
> associated with them (Ie. like the proc/self/fd/* [1], but for each
> user).
> 
>  I'm not saying you should implement the fs above, just that it's
> going to hinder it (or anything like it) if you put shm in the root.
> 
> -- 
> James Antill -- james@and.org
> I am always an optimist, but frankly there is no hope.
>    -Hosni Mubarek
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
