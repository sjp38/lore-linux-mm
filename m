Message-Id: <200005191800.LAA56026@getafix.engr.sgi.com>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits] 
In-reply-to: Your message of "Fri, 19 May 2000 09:17:18 PDT."
             <20000519091718.A4083@skull.piratehaven.org>
Date: Fri, 19 May 2000 11:00:18 -0700
From: Chaitanya Tumuluri <chait@getafix.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Pomerantz <bapper@piratehaven.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 May 2000 09:17:18 PDT, Brian Pomerantz <bapper@piratehaven.org> wrote:
>
>		< stuff snipped >
>
>was set to was 32 (8KB * 32 = 256KB).  So the question I have is in
>the end when you do this pipelining, if you don't increase the atomic
>I/O size, will the device attached to the SCSI bus (or FC) still
>receive a single request or will it quickly see a bunch of smaller
>requests?  My point is, from my experiments with this RAID device, you
>will run across situations where it is good to be able to make a
>single SCSI request be quite large in order to achieve better
>performance.

Agreed. And the patch I've suggested to this list does exactly that. It
allows you to issue large I/Os and the scsi midlayers will take care of
the device sg_tablesize limitations and split/re-issue the large I/O 
into smaller sg_tablesize I/Os till the entire request is done. 

So, the limitation (at least in the rawio path) would only be the HBA 
sg_tablesize. You wouldn't even have to endure the wait in the request
queue, since these multiple sg_tablesize requests would be inserted at
the head of the queue and the dispatch function for the queue called
immediately (i.e. no _undue_ plugging/unplugging of the device queues).

Cheers,
-Chait.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
