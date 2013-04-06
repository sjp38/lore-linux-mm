Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id F04B66B0141
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 06:03:39 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id w12so2438720bku.8
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 03:03:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKb7Uvgxm7ouX0AvPo=eLGn_ruJK7FMCaEMVyK8HxhQ3Ekk0sQ@mail.gmail.com>
References: <CAKb7UviwOk9asT=WxYgDUzfm3J+tGXobroUycpoTvzOX5kkofQ@mail.gmail.com>
	<0000013dc73c284d-29fd15db-416b-40cc-81b6-81abc5bd3c02-000000@email.amazonses.com>
	<CAKb7Uvgxm7ouX0AvPo=eLGn_ruJK7FMCaEMVyK8HxhQ3Ekk0sQ@mail.gmail.com>
Date: Sat, 6 Apr 2013 06:03:37 -0400
Message-ID: <CAKb7Uvjza68+W58=1UHuQxg5M=P7kM+rcwa7A1NEEfcDHPggAQ@mail.gmail.com>
Subject: Re: system death under oom - 3.7.9
From: Ilia Mirkin <imirkin@alum.mit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org

On Sat, Apr 6, 2013 at 5:01 AM, Ilia Mirkin <imirkin@alum.mit.edu> wrote:
> On Mon, Apr 1, 2013 at 4:14 PM, Christoph Lameter <cl@linux.com> wrote:
>> On Wed, 27 Mar 2013, Ilia Mirkin wrote:
>>
>>> The GPF happens at +160, which is in the argument setup for the
>>> cmpxchg in slab_alloc_node. I think it's the call to
>>> get_freepointer(). There was a similar bug report a while back,
>>> https://lkml.org/lkml/2011/5/23/199, and the recommendation was to run
>>> with slub debugging. Is that still the case, or is there a simpler
>>> explanation? I can't reproduce this at will, not sure how many times
>>> this has happened but definitely not many.
>>
>> slub debugging will help to track down the cause of the memory corruption.
>
> OK, with slub_debug=FZP, I get (after a while):
>
> http://pastebin.com/cbHiKhdq
>
> Which definitely makes it look like something in the nouveau
> context/whatever alloc failure path causes some stomping to happen. (I
> don't suppose it's reasonable to warn when the stomping happens
> through some sort of page protection... would explode the size since
> each n-byte object would be at least 4K, but might be worth it for
> debugging...)

OK, after staring for a while at this code, I found an issue, and
looks like it's already fixed by
cfd376b6bfccf33782a0748a9c70f7f752f8b869 (drm/nouveau/vm: fix memory
corruption when pgt allocation fails), which didn't make it into
3.7.9, but is in 3.7.10. Time to upgrade, I guess. Thanks for the
various suggestions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
