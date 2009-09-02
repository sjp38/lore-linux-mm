Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 871326B004F
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 15:31:52 -0400 (EDT)
From: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Date: Wed, 2 Sep 2009 12:30:59 -0700
Subject: RE: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <9EECC02A4CC333418C00A85D21E893260184184010@azsmsx502.amr.corp.intel.com>
References: <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com>
 <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org>
 <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org>
 <20090814095106.GA3345@localhost> <4A856467.6050102@redhat.com>
 <20090815054524.GB11387@localhost>
 <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com>
 <20090818022609.GA7958@localhost>
In-Reply-To: <20090818022609.GA7958@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm trying to better understand the motivation for your make-mapped-exec-pa=
ges-first-class-citizens patch.  As I read your (very detailed!) descriptio=
n, you are diagnosing a threshold effect from Rik's evict-use-once-pages-fi=
rst patch where if the inactive list is slightly smaller than the active li=
st, the active list will start being scanned, pushing text (and other) page=
s onto the inactive list where they will be quickly kicked out to swap.

As I read Rik's patch, if the active list is one page larger than the inact=
ive list, then a batch of pages will get moved from one to the other.  For =
this to have a noticeable effect on the system once the streaming is done, =
there must be something continuing to keep the active list larger than the =
inactive list.  Maybe there is a consistent percentage of the streamed page=
s which are use-twice.=20

So, we a threshold effect where a small change in input (the size of the st=
reaming file vs the number of active pages) causes a large change in output=
 (lots of text pages suddenly start getting thrown out).   My immediate rea=
ction to that is that there shouldn't be this sudden change in behavior, an=
d that maybe there should only be enough scanning in shink_active_list to b=
ring the two lists back to parity.  However, if there's something keeping t=
he active list bigger than the inactive list, this will just put off the in=
evitable required scanning.

As for your patch, it seems like we have a problem with scanning I/O, and i=
nstead of looking at those pages, you are looking to protect some other set=
 of pages (mapped text).  That, in turn, increases pressure on anonymous pa=
ges (which is where I came in).  Wouldn't it be a better idea to keep looki=
ng at those streaming pages and figure out how to get them out of memory qu=
ickly?

						Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
