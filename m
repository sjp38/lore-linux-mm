Received: from host-76.subnet-242.amherst.edu
 (sfkaplan@host-76.subnet-242.amherst.edu [148.85.242.76])
 by amherst.edu (PMDF V5.2-33 #45524)
 with ESMTP id <01K1OPC4AS7WA0VJZO@amherst.edu> for linux-mm@kvack.org; Tue,
 27 Mar 2001 09:04:40 EST
Date: Tue, 27 Mar 2001 09:05:20 -0500 (EST)
From: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: [PATCH] Prevent OOM from killing init
In-reply-to: 
        <Pine.LNX.4.21.0103240255090.1863-100000@imladris.rielhome.conectiva>
Message-id: <Pine.LNX.4.21.0103270854350.25071-100000@localhost.localdomain>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Sat, 24 Mar 2001, Rik van Riel wrote:

> [...]  I need to implement load control code (so we suspend
> processes in turn to keep the load low enough so we can avoid
> thrashing).

I am curious as to how you plan to go about implementing this load
control.  I ask because it's a current area of research for me.
Detecting the point at which thrashing occurs (that is, the point at
which process utilization starts to fall because every active process
is waiting for page faults, and nothing is ready to run) is not
necessarily easy.

There was a whole bunch of theory about how to detect this kind of
over-commitment with Working Set.  Unfortunately, I'm reasonably
convinced that there are some serious holes in that theory, and that
nobody has developed a well founded answer to this question.  Do you
have ideas (taken from others or developed yourself) about how you're
going to approach it?

My specific concerns are things like:  What will your definition of
"thrashing" be?  How do you plan to detect it?  When you suspend a
process, what will happen to that process?  Will its main memory
allocation be taken away immediately?  When will it be re-activated?

Basically, these problems used to have easier answers on old batch
systems with a lesser notion of fairness and more uniform workloads.
It's not clear what to do here; by suspending processes, you're
introducing a kind of long-term scheduler that decides when a process
can enter the pool of candidates from which the usual, short-term
scheduler chooses.  There seems to be some real scheduling issues that
go along with this problem, including a substantial modification to
the fairness with which suspended processes are treated.

I'd like very much to see a well developed, generalized model for this
kind of problem.  Obviously, the answer will depend on what the
intended use of the system is.  It would be wonderful to avoid ad-hoc
solutions for different cases, and instead have one approach that can
be adjusted to serve different needs.

Scott Kaplan
sfkaplan@cs.amherst.edu

p.s.  I recognize that solving this problem isn't necessarily the
highest priority for Linux.  I'm just curious as to everyone's
thoughts, as I find it an interesting problem.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE6wJ4R8eFdWQtoOmgRAtq5AJsE65/+K4tsj8MngAs0uYTw7JTnJQCgkNSz
hMcPq+hdvqADsofb2XOx3Ng=
=I/TJ
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
