Message-Id: <200005191753.KAA70966@getafix.engr.sgi.com>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits] 
In-reply-to: Your message of "Fri, 19 May 2000 16:55:02 BST."
             <20000519165502.G9961@redhat.com>
Date: Fri, 19 May 2000 10:53:23 -0700
From: Chaitanya Tumuluri <chait@getafix.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 May 2000 16:55:02 BST, "Stephen C. Tweedie" <sct@redhat.com> wrote:
>Hi,
>
>On Fri, May 19, 2000 at 08:48:42AM -0700, Brian Pomerantz wrote:
>
>> > The real solution is probably not to increase the atomic I/O size, but
>> > rather to pipeline I/Os.  That is planned for the future, and now there
>> 
>> That really depends on the device characteristics.  This Ciprico
>> hardware I've been working with really only performs well if the
>> atomic I/O size is >= 1MB.  Once you introduce additional transactions
>> across the bus, your performance drops significantly.  I guess it is a
>> tradeoff between latency and bandwidth.  Unless you mean the low level
>> device would be handed a vector of kiobufs and it would build a single
>> SCSI request with that vector,

Hmm...I was thinking more along the lines of kiobuf abstraction being limited
to the scsi midlayer and the low-level device (HBA/disk driver) being handed
a linked list of Scsi_Cmnds, each containing at most the HBA sg_tablesize of
I/O. The chaining of such Scsi_Cmnd structs is not possible currently and 
might be the way to go. Each Scsi_Cmnd in the chain would represent one 
kiobuf-based I/O request at a time. 

>ll_rw_block can already do that, but...
>
>> then I suppose it would work well but
>> the requests would have to make up a contiguous chunk of drive space.
>
>... a single request _must_, by definition, be contiguous.  There is
>simply no way for the kernel to deal with non-contiguous atomic I/Os.
>I'm not sure what you're talking about here --- how can an atomic I/O
>be anything else?  We can do scatter-gather, but only from scattered
>memory, not to scattered disk blocks.

And that could potentially be handled via the linked list of Scsi_Cmnd 
structs that I mention above. Each I/O within a Scsi_Cmnd would be restricted 
to contiguous disk blocks but that needn't apply across the linked list.

Cheers,
-Chait.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
