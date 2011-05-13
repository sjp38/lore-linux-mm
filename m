Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1CA6B0024
	for <linux-mm@kvack.org>; Fri, 13 May 2011 01:39:05 -0400 (EDT)
Received: by qyk30 with SMTP id 30so1618049qyk.14
        for <linux-mm@kvack.org>; Thu, 12 May 2011 22:39:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikRFjGtBhnTBH_n=rDe+Y6kCjt30g@mail.gmail.com>
References: <1305127773-10570-4-git-send-email-mgorman@suse.de>
	<alpine.DEB.2.00.1105120942050.24560@router.home>
	<1305213359.2575.46.camel@mulgrave.site>
	<alpine.DEB.2.00.1105121024350.26013@router.home>
	<1305214993.2575.50.camel@mulgrave.site>
	<1305215742.27848.40.camel@jaguar>
	<1305225467.2575.66.camel@mulgrave.site>
	<1305229447.2575.71.camel@mulgrave.site>
	<1305230652.2575.72.camel@mulgrave.site>
	<1305237882.2575.100.camel@mulgrave.site>
	<20110512221506.GM16531@cmpxchg.org>
	<BANLkTikRFjGtBhnTBH_n=rDe+Y6kCjt30g@mail.gmail.com>
Date: Fri, 13 May 2011 14:39:03 +0900
Message-ID: <BANLkTimmn_PyU0xtfnG-CKxDxd1CTKx=Aw@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 13, 2011 at 7:58 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, May 13, 2011 at 7:15 AM, Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>> On Thu, May 12, 2011 at 05:04:41PM -0500, James Bottomley wrote:
>>> On Thu, 2011-05-12 at 15:04 -0500, James Bottomley wrote:
>>> > Confirmed, I'm afraid ... I can trigger the problem with all three
>>> > patches under PREEMPT. =C2=A0It's not a hang this time, it's just ksw=
apd
>>> > taking 100% system time on 1 CPU and it won't calm down after I unloa=
d
>>> > the system.
>>>
>>> Just on a "if you don't know what's wrong poke about and see" basis, I
>>> sliced out all the complex logic in sleeping_prematurely() and, as far
>>> as I can tell, it cures the problem behaviour. =C2=A0I've loaded up the
>>> system, and taken the tar load generator through three runs without
>>> producing a spinning kswapd (this is PREEMPT). =C2=A0I'll try with a
>>> non-PREEMPT kernel shortly.
>>>
>>> What this seems to say is that there's a problem with the complex logic
>>> in sleeping_prematurely(). =C2=A0I'm pretty sure hacking up
>>> sleeping_prematurely() just to dump all the calculations is the wrong
>>> thing to do, but perhaps someone can see what the right thing is ...
>>
>> I think I see the problem: the boolean logic of sleeping_prematurely()
>> is odd. =C2=A0If it returns true, kswapd will keep running. =C2=A0So if
>> pgdat_balanced() returns true, kswapd should go to sleep.
>>
>> This?
>
> Yes. Good catch.

In addition, I see some strange thing.
The comment in pgdat_balanced says
"Only zones that meet watermarks and are in a zone allowed by the
callers classzone_idx are added to balanced_pages"

It's true in case of balance_pgdat but it's not true in sleeping_prematurel=
y.
This?

barrios@barrios-desktop:~/linux-mmotm$ git diff mm/vmscan.c
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 292582c..d9078cf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2322,7 +2322,8 @@ static bool sleeping_prematurely(pg_data_t
*pgdat, int order, long remaining,
                                                        classzone_idx, 0))
                        all_zones_ok =3D false;
                else
-                       balanced +=3D zone->present_pages;
+                       if (i <=3D classzone_idx)
+                               balanced +=3D zone->present_pages;
        }

        /*
@@ -2331,7 +2332,7 @@ static bool sleeping_prematurely(pg_data_t
*pgdat, int order, long remaining,
         * must be balanced
         */
        if (order)
-               return pgdat_balanced(pgdat, balanced, classzone_idx);
+               return !pgdat_balanced(pgdat, balanced, classzone_idx);
        else
                return !all_zones_ok;
 }





--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
