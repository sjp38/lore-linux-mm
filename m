Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA20233
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 04:32:09 -0400
Subject: Re: Thread implementations...
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
	<m1u35a4fz8.fsf@flinx.npwt.net>
	<199806242341.JAA15101@vindaloo.atnf.CSIRO.AU>
	<m1pvfy3x8f.fsf@flinx.npwt.net> <qww4sx8r44b.fsf@p21491.wdf.sap-ag.de>
	<m1k964fdu9.fsf@flinx.npwt.net>
	<199806291019.LAA00726@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 30 Jun 1998 01:19:18 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Mon, 29 Jun 1998 11:19:37 +0100
Message-ID: <m1vhpj8l95.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> On 26 Jun 1998 09:16:14 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

>>>>>>> "CR" == Christoph Rohland <hans-christoph.rohland@sap-ag.de> writes:

CR> 1) why should madvise only advise. 

>> Because if it only advises, you can ignore it and return success.
>> If it does more than advise you have to do much more error checking
>> and error handling.  

ST> Not necessarily; even if we do take immediate action on the advise,
ST> within the madvise system call, we don't have to do any extra layers of
ST> error handling.   It's more a case of "Please try to do this now / OK, I
ST> tried."

The semantics for some of one or two of the implimentation specific
madvise options were more much more like mlock...  And for that you
need extra error checking to confirm that success occured.

The try this now I see as a totally appropriate implementation.

CR> 2) Would not work on shared pages.
>> Not perfectly.  That does appear to be the achillies heel currently of
>> madvise.  Multiple users of the same memory.

ST> Again, madvise is the application telling us that it KNOWS what the
ST> access pattern is.  If the app is wrong, and the page is shared, big
ST> deal; throw away the advise, it was duff. :)

Again the case was: I have a multithreaded web server serving up
files.  The web server mmaps each file, and calls 
madvise(file_start, file_len, MADV_SEQUENTIAL).    The trick is that
it may be serving the say file to two different clients
simultaneously.

MADV_SEQUENTIAL implies readahead, and forget behind, but for a simple
process.

The forget behind is tricky and difficult to get right, but if we
concentrate on aggressive readahead (in this  we will probably be
o.k.)

And some readahead we already have implemented filemap_nopage.
Getting it general for the whole mm layer could be fun but it is
certainly doable.  Though at the moment putting hint information in
the vm_area_struct, and keeping the implemetation in the nopage functions
sounds like the way to go.  

Eric
