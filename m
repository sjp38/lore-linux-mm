content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: mapping user data in kernel
Date: Wed, 2 Mar 2005 08:31:47 +0100
Message-ID: <22326A72AE6CF647B89C8371452F6BFA272621@frex02.fr.nds.com>
From: "Hermann, Guy" <GHermann@nds.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: linux-mm@kvack.org, "Andrieux, Fabien" <fandrieux@nds.com>
List-ID: <linux-mm.kvack.org>

thanks for the answer Christoph,

I understand what did not work in our previsous try,
but as you probably have guessed the problem is more complex than
sharing memory between user processes (shm_open).


The real need we have is to provide a new filesystem called xxxFS
inserted in the kernel as a module. The raw data containing the data of the
the xxxFS are formatted and can only be handled by xxxFS: they are nevertheless
available, once interpreted by the xxxFS, to user processes thanks
to the open/read/close POSIX functions.


The critical functional points/constraints are the following:

-1.the xxxFS, which is in the kernel, should receive its raw data
during the read_super_block (mount)

-2.the raw data are known by xxxFS thanks to their address (the xxxFS
directly accesses the raw data without driver/device)

-3.we don't want that the symbol pointing the address be used in
the code of the xxxFS -> for link reasons we don't wan't that the
module contains  a symbol that points the raw data of the xxxFS

-4.so the address of xxxFS raw data should come from a user process

-5.but since xxxFS is a filesystem, it should access the raw data
even if the FS syscalls are done in the context of a process that
didn't provide the raw data address

-6.we did not know, a priori, the other processes that will access
the xxxFS data


I would like to know if these constraints are relevant and not contradictory?

If there is a contradiction, then we will cancel the constraints
that are problematic.

Thanks for your help

GH


-----Message d'origine-----
De : Christoph Lameter [mailto:christoph@graphe.net]De la part de
Christoph Lameter
Envoye : mercredi 23 fevrier 2005 17:07
A : Hermann, Guy
Cc : linux-mm@kvack.org
Objet : Re: mapping user data in kernel


On Wed, 23 Feb 2005, Hermann, Guy wrote:

> The general idea consists in a user process that gives data from its userspace to the kernel.
> And the kernel makes them available to other user processes.

There is already a shared memory implementation in Linux that allows the
sharing of data between processes.

See shm_open

> 1st question:
> Is such a treament (mapping in the kernel a page belonging to a user process that is not the
> current one) relevant ? (can we use pgd_offset for a task->mm that does not belong to the current
> process?)

Yes, the kernel is able to map the same page into the address spaces of
multiple processes. And no, the page tables are separate thus you
wont be able to use addresses of page tables pages from one process for
the next.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
