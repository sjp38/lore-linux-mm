Date: Fri, 12 May 2000 01:25:43 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005102204370.1155-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005120113520.10596-200000@elte.hu>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="79888902-1708015733-958087543=:10596"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

--79888902-1708015733-958087543=:10596
Content-Type: TEXT/PLAIN; charset=US-ASCII


IMO high memory should not be balanced. Stock pre7-9 tried to balance high
memory once it got below the treshold (causing very bad VM behavior and
high kswapd usage) - this is incorrect because there is nothing special
about the highmem zone, it's more like an 'extension' of the normal zone,
from which specific caches can turn. (patch attached)

another problem is that even during a mild test the DMA zone gets emptied
easily - but on a big RAM box kswapd has to work _alot_ to fill it up. In
fact on an 8GB box it's completely futile to fill up the DMA zone. What
worked for me is this zone-chainlist trick in the zone setup code:

                        case ZONE_NORMAL:
                                zone = pgdat->node_zones + ZONE_NORMAL;
                                if (zone->size)
                                        zonelist->zones[j++] = zone;
++                              break;
                        case ZONE_DMA:
                                zone = pgdat->node_zones + ZONE_DMA;
                                if (zone->size)
                                        zonelist->zones[j++] = zone;

no 'normal' allocation chain leads to the ZONE_DMA zone, except GFP_DMA
and GFP_ATOMIC - both of them rightfully access the DMA zone.

this is a RL problem, without the above a 8GB box under load crashes
pretty quickly due to failed SCSI-layer DMA allocations. (i think those
allocations are silly in the first place.)

the above is suboptimal on boxes which have total RAM within one order of
magnitude of 16MB (the DMA zone stays empty most of the time and is
unaccessible to various caches) - so maybe the following (not yet
implemented) solution would be generic and acceptable:

allocate 5% of total RAM or 16MB to the DMA zone (via fixing up zone sizes
on bootup), whichever is smaller, in 2MB increments. Disadvantage of this
method: eg. it wastes 2MB RAM on a 8MB box. We could probably live with
64kb increments (there are 64kb ISA DMA constraints the sound drivers and
some SCSI drivers are hitting) - is this really true? If nobody objects
i'll implement this later one (together with the assymetric allocation
chain trick) - there will be a 64kb DMA pool allocated on the smallest
boxes, which should be acceptable even on a 4MB box. We could turn off the
DMA zone altogether on most boxes, if it wasnt for the SCSI layer
allocating DMA pages even for PCI drivers ...

Comments?

	Ingo

--79888902-1708015733-958087543=:10596
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="highmem-2.3.99-7-A0"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.10.10005120125430.10596@elte.hu>
Content-Description: 
Content-Disposition: attachment; filename="highmem-2.3.99-7-A0"

LS0tIGxpbnV4L21tL3BhZ2VfYWxsb2MuYy5vcmlnCVRodSBNYXkgMTEgMDI6
MTA6MzQgMjAwMA0KKysrIGxpbnV4L21tL3BhZ2VfYWxsb2MuYwlUaHUgTWF5
IDExIDE2OjAzOjQ4IDIwMDANCkBAIC01NTMsOSArNTY2LDE0IEBADQogCQkJ
bWFzayA9IHpvbmVfYmFsYW5jZV9taW5bal07DQogCQllbHNlIGlmIChtYXNr
ID4gem9uZV9iYWxhbmNlX21heFtqXSkNCiAJCQltYXNrID0gem9uZV9iYWxh
bmNlX21heFtqXTsNCi0JCXpvbmUtPnBhZ2VzX21pbiA9IG1hc2s7DQotCQl6
b25lLT5wYWdlc19sb3cgPSBtYXNrKjI7DQotCQl6b25lLT5wYWdlc19oaWdo
ID0gbWFzayozOw0KKwkJaWYgKGogPT0gWk9ORV9ISUdITUVNKSB7DQorCQkJ
em9uZS0+cGFnZXNfbG93ID0gem9uZS0+cGFnZXNfaGlnaCA9DQorCQkJCQkJ
em9uZS0+cGFnZXNfbWluID0gMDsNCisJCX0gZWxzZSB7DQorCQkJem9uZS0+
cGFnZXNfbWluID0gbWFzazsNCisJCQl6b25lLT5wYWdlc19sb3cgPSBtYXNr
KjI7DQorCQkJem9uZS0+cGFnZXNfaGlnaCA9IG1hc2sqMzsNCisJCX0NCiAJ
CXpvbmUtPmxvd19vbl9tZW1vcnkgPSAwOw0KIAkJem9uZS0+em9uZV93YWtl
X2tzd2FwZCA9IDA7DQogCQl6b25lLT56b25lX21lbV9tYXAgPSBtZW1fbWFw
ICsgb2Zmc2V0Ow0K
--79888902-1708015733-958087543=:10596--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
