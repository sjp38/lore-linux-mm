Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id A067E280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:21:54 -0400 (EDT)
Received: by lblf12 with SMTP id f12so12892640lbl.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 13:21:54 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id l1si1899578lbj.175.2015.07.14.13.21.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 13:21:53 -0700 (PDT)
Received: by lagw2 with SMTP id w2so12719398lag.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 13:21:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1507141304430.28065@east.gentwo.org>
References: <20150714131704.21442.17939.stgit@buzz>
	<20150714131705.21442.99279.stgit@buzz>
	<alpine.DEB.2.11.1507141304430.28065@east.gentwo.org>
Date: Tue, 14 Jul 2015 23:21:52 +0300
Message-ID: <CALYGNiPKgfE+KNNgmW0ZGrFqU4NSsz_vm14Zu2gXFyjPWnE57g@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/slub: disable merging after enabling debug in runtime
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jul 14, 2015 at 9:11 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 14 Jul 2015, Konstantin Khlebnikov wrote:
>
>> Enabling debug in runtime breaks creation of new kmem caches:
>> they have incompatible flags thus cannot be merged but unique
>> names are taken by existing caches.
>
> What breaks?

The same commands from first patch:

# echo 1 | tee /sys/kernel/slab/*/sanity_checks
# modprobe configfs

loading configfs now fails (without crashing kernel though) because of
"sysfs: cannot create duplicate filename '/kernel/slab/:t-0000096'"

Of course we could rename sysfs entry when enable debug options
but that requires much more code than my "stop merging" solution.

>
> Caches may already have been merged and thus the question is what to do
> about a cache that has multiple aliases if a runtime option is requested.
> The solution that slub implements is to only allow a limited number of
> debug operations to be enabled. Those then will appear to affect all
> aliases of course.
>
> Creating additional caches later may create additional
> aliasing which will then restrict what options can be changed.
>
> Other operations are also restricted depending on the number of objects
> stored in a cache. A cache with zero objects can be easily reconfigured.
> If there are objects then modifications that impact object size are not
> allowed anymore.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
