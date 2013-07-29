Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4DDE46B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 12:43:36 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id ij15so2252996vcb.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 09:43:35 -0700 (PDT)
Message-ID: <51F69BD7.2060407@gmail.com>
Date: Mon, 29 Jul 2013 12:44:07 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Possible deadloop in direct reclaim?
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com> <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com> <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com> <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com> <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com>
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>

(7/25/13 9:11 PM), Lisa Du wrote:
> Dear KOSAKI
>     In my test, I didn't set compaction. Maybe compaction is helpful to avoid this issue. I can have try later.
>     In my mind CONFIG_COMPACTION is an optional configuration right?

Right. But if you don't set it, application must NOT use >1 order allocations. It doesn't work and it is expected
result.
That's your application mistake.

>     If we don't use, and met such an issue, how should we deal with such infinite loop?
> 
>     I made a change in all_reclaimable() function, passed overnight tests, please help review, thanks in advance!
> @@ -2353,7 +2353,9 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>                          continue;
>                  if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>                          continue;
> -               if (!zone->all_unreclaimable)
> +               if (zone->all_unreclaimable)
> +                       continue;
> +               if (zone_reclaimable(zone))
>                          return false;

Please tell me why you chaned here.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
