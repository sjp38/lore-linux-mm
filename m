Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12F3D6B0038
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 14:16:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so79909249lfg.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 11:16:49 -0700 (PDT)
Received: from mx0a-000cda01.pphosted.com (mx0b-00003501.pphosted.com. [67.231.152.68])
        by mx.google.com with ESMTPS id l2si17302195wmi.63.2016.08.22.11.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 11:16:47 -0700 (PDT)
Received: from pps.filterd (m0075033.ppops.net [127.0.0.1])
	by mx0b-00003501.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7MIFIAV024501
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 14:16:46 -0400
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by mx0b-00003501.pphosted.com with ESMTP id 2504360nux-57
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 14:16:45 -0400
Received: by mail-ua0-f200.google.com with SMTP id u13so253006898uau.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 11:16:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160817114320.GA20719@dhcp22.suse.cz>
References: <CAK-uSPo9Nc-1HaURvwstOGYGuMEx4CXhPRv+cZevYLZX6URzYw@mail.gmail.com>
 <20160817114320.GA20719@dhcp22.suse.cz>
From: Andriy Tkachuk <andriy.tkachuk@seagate.com>
Date: Mon, 22 Aug 2016 19:16:44 +0100
Message-ID: <CAK-uSPpViZma5CG4znAhQ0=XPqVaj1PG8RRyxQLfXjKSd-DjDQ@mail.gmail.com>
Subject: Re: mm: kswapd struggles reclaiming the pages on 64GB server
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

Hi Michal.

Thank you for the reply.

It looks like the root cause of the problems we are facing is a bit
different, although the ultimate effect is similar - bad swapping
effectiveness.

As far as I could understand, Johannes tries to fix the balancing
between anon and file lists. But in my case it looks like the anon
pages which are idle for a long time and could be swapped out - they
all are just sitting in active list and don't move to inactive without
a chance to be scanned and eventually swapped out. (See the
/proc/vmstat samples and explanations in my prev. mail. BTW, the
samples interval is 10 secs there, not the 5. My typo.)

It looks like in my case the system load activity enters a steady mode
when all the scanned pages from inactive list become referenced very
soon. So kswapd aggresively scans, but mostly the inactive list where
it can hardly find to reclaim anything. So the inactive list is not
shortened and, as result, is not refilled from the active one. That's
why the anon pages from active list are not even get a chance to be
scanned. Note: the zone's inactive_ratio is more than 10 on 64GB RAM
systems, so the inactive list is much smaller than active in my case.

  Andriy

On Wed, Aug 17, 2016 at 12:43 PM, Michal Hocko <mhocko@kernel.org> wrote:
> [CCing linux-mm and Johannes]
>
>
> I haven't looked at your numbers deeply but this smells like the long
> standing problem/limitation we have. We are trying really hard to not
> swap out and rather reclaim the page cache because the swap refault
> tends to be more disruptive in many case. Not all, though, and trashing
> like behavior you see is cetainly undesirable.
>
> Johannes has been looking into that area recently. Have a look at
> https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__lkml.kernel.org_r_2=
0160606194836.3624-2D1-2Dhannes-40cmpxchg.org&d=3DDQIBAg&c=3DIGDlg0lD0b-neb=
mJJ0Kp8A&r=3DrP2MQ-RHGa6a64ebEAbeV_m6Ae_GOWHWTIpipamZCdE&m=3DMxava1puJmDToy=
ZNc62FshgwDC66k26arjHAM6o54yI&s=3DwmYJ3WdYDc73B7hO75xxvmIk0hDoTUSjGH-KxSC48=
SA&e=3D
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
