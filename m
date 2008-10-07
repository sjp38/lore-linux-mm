MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18667.33351.854693.368568@harpo.it.uu.se>
Date: Tue, 7 Oct 2008 17:37:43 +0200
From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
	for adaptive dcache hash table sizing (resend)
In-Reply-To: <20081007071827.GB5010@infradead.org>
References: <20081007064834.GA5959@wotan.suse.de>
	<20081007070225.GB5959@wotan.suse.de>
	<20081007071827.GB5010@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig writes:
 > On Tue, Oct 07, 2008 at 09:02:25AM +0200, Nick Piggin wrote:
 > > (resending with correct netdev address)
 > > 
 > > Hi,
 > > 
 > > I thought I should quickly bring this patch up to date and write it up
 > > properly, because IMO it is still useful. I earlier had tried to turn the
 > > algorithm into a library that could be plugged into with specific lookup
 > > functions and such, but that got really nasty and also difficult to retain
 > > a really light fastpath. I don't think it is too nasty to open-code it...
 > > 
 > > Describe the "Dynamic dynamic data structure" (DDDS) algorithm, and implement
 > > adaptive dcache hash table sizing using DDDS.
 > > 
 > > The dcache hash size is increased to the next power of 2 if the number
 > > of dentries exceeds the current size of the dcache hash table. It is decreased
 > > in size if it is currently more than 3 times the number of dentries.
 > > 
 > > This might be a dumb thing to do. It also currently performs the hash resizing
 > > check for each dentry insertion/deletion, and calls the resizing in-line from
 > > there: that's bad, because resizing takes several RCU grace periods. Rather it
 > > should kick off a thread to do the resizing, or even have a background worker
 > > thread checking the sizes periodically and resizing if required.
 > > 
 > > With this algorithm, I can fit a whole kernel source and git tree in my dcache
 > > hash table that is still 1/8th the size it would be before the patch.
 > > 
 > > I'm cc'ing netdev because Dave did express some interest in using this for
 > > some networking hashes, and network guys in general are pretty cluey when it
 > > comes to hashes and such ;)

I missed the first post, but loooking at the patch it seems
somewhat complex.

How does this relate to traditional incremental hash tables
like extensible hashing or linear hashing (not to be confused
with linear probing)? In linear hashing a resize only affects
a single collision chain at a time, and reads from other chains
than the one being resized are unaffected.

(I can dig up some references if need be.)

/Mikael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
