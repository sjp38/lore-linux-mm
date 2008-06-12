Message-ID: <485178A8.2040002@cs.helsinki.fi>
Date: Thu, 12 Jun 2008 22:27:36 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: repeatable slab corruption with LTP msgctl08
References: <20080611221324.42270ef2.akpm@linux-foundation.org> <Pine.LNX.4.64.0806121332130.11556@sbz-30.cs.Helsinki.FI> <48516BF3.8050805@colorfullife.com>
In-Reply-To: <48516BF3.8050805@colorfullife.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Derbey <Nadia.Derbey@bull.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Manfred Spraul wrote:
> Hmm. double kfree() should be cached by the redzone code.
> And I disagree with your link interpretation:
> 
> 000: 00 e0 12 f2 88 32 c0 f7 88 00 00 00 88 50 90 f2
> 010:
> inuse: 14 00 00 00 (20 entries in use, 6 should be free)
> free:  0f 00 00 00
> nodeid: 00 00 00 00
> bufctl[0x00] ff ff ff ff 020: fd ff ff ff fd ff ff ff fd ff ff ff
> bufctl[0x4] fd ff ff ff  030: fd ff ff ff fd ff ff ff fd ff ff ff
> bufctl[0x8] fd ff ff ff  040: fd ff ff ff fd ff ff ff 00 00 00 00
> bufctl[0x0c] fd ff ff ff 050: fd ff ff ff fd ff ff ff 19 00 00 00
> bufctl[0x10] 17 00 00 00 060: fd ff ff ff fd ff ff ff 0b 00 00 00
> bufctl[0x14] fd ff ff ff 070: fd ff ff ff fd ff ff ff fd ff ff ff
> bufctl[0x18] fd ff ff ff 080: 10 00 00 00
> 
> free: points to entry 0x0f.
> bufctl[0x0f] is 0x19, i.e. it points to entry 0x19
> 0x19 points to 0x10
> 0x10 points to 0x17
> 0x17 is a BUFCTL_ACTIVE - that's a bug.
> but: 0x13 is a valid link entry, is points to 0x0b
> 0x0b points to 0x00, which is BUFCTL_END.
> 
> IMHO the most probable bug is a single bit error:
> bufctl[0x10] should be 0x13 instead of 0x17.

Ah, you're, of course, right. For some reason I was looking at 8-bit 
bufctls when they are, in fact, 32-bit.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
