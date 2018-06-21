Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BAAE6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 21:42:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c9-v6so1274492ioi.20
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:42:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z6-v6si2531653ioz.18.2018.06.20.18.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 18:42:18 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5L1cqwH021396
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:42:17 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2jmtgwxt2h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:42:17 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5L1gH9Q019267
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:42:17 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5L1gH8J008430
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:42:17 GMT
Received: by mail-ot0-f181.google.com with SMTP id r18-v6so1756584otk.1
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:42:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180601125321.30652-1-osalvador@techadventures.net>
 <20180601125321.30652-2-osalvador@techadventures.net> <20180620151819.3f39226998bd80f7161fcea5@linux-foundation.org>
In-Reply-To: <20180620151819.3f39226998bd80f7161fcea5@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 20 Jun 2018 21:41:35 -0400
Message-ID: <CAGM2reYgrpBrfhcw0O7K+sMU-qE-U_+2MzJWsG=7gSbU8n-=kA@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/memory_hotplug: Make add_memory_resource use __try_online_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: osalvador@techadventures.net, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

> I don't think __try_online_node() will ever return a value greater than
> zero.  I assume what was meant was

Hi Andrew and Oscar,

Actually, the new __try_online_node()  returns:
1 -> a new node was allocated
0 -> node is already online
-error -> an error encountered.

The function simply missing the return comment at the beginning.

Oscar, please check it via ./scripts/checkpatch.pl

Add comment explaining the return values.

And change:
        ret = __try_online_node (nid, start, false);
        new_node = !!(ret > 0);
        if (ret < 0)
                goto error;
To:
        ret = __try_online_node (nid, start, false);
        if (ret < 0)
                goto error;
        new_node = ret;

Other than that the patch looks good to me, it simplifies the code.
So, if the above is addressed:

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Thank you,
Pavel

>
>         new_node = !!(ret >= 0);
>
> which may as well be
>
>         new_node = (ret >= 0);
>
> since both sides have bool type.
>
> The fact that testing didn't detect this is worrisome....
>
> > +     if (ret < 0)
> > +             goto error;
> > +
> >
> >       /* call arch's memory hotadd */
> >       ret = arch_add_memory(nid, start, size, NULL, true);
> > -
> >       if (ret < 0)
> >               goto error;
> >
> >
> > ...
> >
>
