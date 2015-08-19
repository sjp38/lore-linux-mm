Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4DC6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 10:21:52 -0400 (EDT)
Received: by iods203 with SMTP id s203so10568593iod.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:21:51 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id qm12si1988122igb.52.2015.08.19.07.21.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 07:21:51 -0700 (PDT)
Received: by iods203 with SMTP id s203so10568234iod.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:21:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55D48C5E.7010004@suse.cz>
References: <1439924830-29275-1-git-send-email-ddstreet@ieee.org> <55D48C5E.7010004@suse.cz>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 19 Aug 2015 10:21:10 -0400
Message-ID: <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
Subject: Re: [PATCH] zswap: update docs for runtime-changeable attributes
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Aug 19, 2015 at 10:02 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 08/18/2015 09:07 PM, Dan Streetman wrote:
>> Change the Documentation/vm/zswap.txt doc to indicate that the "zpool"
>> and "compressor" params are now changeable at runtime.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  Documentation/vm/zswap.txt | 31 +++++++++++++++++++++++--------
>>  1 file changed, 23 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
>> index 8458c08..06f7ce2 100644
>> --- a/Documentation/vm/zswap.txt
>> +++ b/Documentation/vm/zswap.txt
>> @@ -32,7 +32,7 @@ can also be enabled and disabled at runtime using the =
sysfs interface.
>>  An example command to enable zswap at runtime, assuming sysfs is mounte=
d
>>  at /sys, is:
>>
>> -echo 1 > /sys/modules/zswap/parameters/enabled
>> +echo 1 > /sys/module/zswap/parameters/enabled
>>
>>  When zswap is disabled at runtime it will stop storing pages that are
>>  being swapped out.  However, it will _not_ immediately write out or fau=
lt
>> @@ -49,14 +49,27 @@ Zswap receives pages for compression through the Fro=
ntswap API and is able to
>>  evict pages from its own compressed pool on an LRU basis and write them=
 back to
>>  the backing swap device in the case that the compressed pool is full.
>>
>> -Zswap makes use of zbud for the managing the compressed memory pool.  E=
ach
>> -allocation in zbud is not directly accessible by address.  Rather, a ha=
ndle is
>> +Zswap makes use of zpool for the managing the compressed memory pool.  =
Each
>> +allocation in zpool is not directly accessible by address.  Rather, a h=
andle is
>>  returned by the allocation routine and that handle must be mapped befor=
e being
>>  accessed.  The compressed memory pool grows on demand and shrinks as co=
mpressed
>> -pages are freed.  The pool is not preallocated.
>> +pages are freed.  The pool is not preallocated.  By default, a zpool of=
 type
>> +zbud is created, but it can be selected at boot time by setting the "zp=
ool"
>> +attribute, e.g. zswap.zpool=3Dzbud.  It can also be changed at runtime =
using the
>> +sysfs "zpool" attribute, e.g.
>> +
>> +echo zbud > /sys/module/zswap/parameters/zpool
>
> What exactly happens if zswap is already being used and has allocated pag=
es in
> one type of pool, and you're changing it to the other one?

zswap has a rcu list where each entry contains a specific compressor
and zpool.  When either the compressor or zpool is changed, a new
entry is created with a new compressor and pool and put at the front
of the list.  New pages always use the "current" (first) entry.  Any
old (unused) entries are freed whenever all the pages they contain are
removed.

So when the compressor or zpool is changed, the only thing that
happens is zswap creates a new compressor and zpool and places it at
the front of the list, for new pages to use.  No existing pages are
touched.

>
>> +
>> +The zbud type zpool allocates exactly 1 page to store 2 compressed page=
s, which
>> +means the compression ratio will always be exactly 2:1 (not including h=
alf-full
>> +zbud pages), and any page that compresses to more than 1/2 page in size=
 will be
>> +rejected (and written to the swap disk).
>
> Hm is this correct? I've been going through the zbud code briefly (as of =
Linus'
> tree) and it seems to me that it will accept pages larger than 1/2, but t=
hey
> will sit in the unbuddied list until a small enough "buddy" comes.

ha, yeah you're right.  I didn't read zbud_alloc closely before, it
definitely takes compressed pages > 1/2 page.  I'll update the doc.

thanks!

>
>> The zsmalloc type zpool has a more
>> +complex compressed page storage method, and it can achieve greater stor=
age
>> +densities.  However, zsmalloc does not implement compressed page evicti=
on, so
>> +once zswap fills it cannot evict the oldest page, it can only reject ne=
w pages.
>
> I still wonder why anyone would use zsmalloc with zswap given this limita=
tion.
> It seems only fine for zram which has no real swap as fallback. And even =
zbud
> doesn't have any shrinker interface that would react to memory pressure, =
so
> there's a possibility of premature OOM... sigh.

for situations where zswap isn't expected to ever fill up, zsmalloc
will outperform zbud, since it has higher density.

i'd argue that neither zbud nor zsmalloc are responsible for reacting
to memory pressure, they just store the pages.  It's zswap that has to
limit its size, which it does with max_percent_pool.

>
>>  When a swap page is passed from frontswap to zswap, zswap maintains a m=
apping
>> -of the swap entry, a combination of the swap type and swap offset, to t=
he zbud
>> +of the swap entry, a combination of the swap type and swap offset, to t=
he zpool
>>  handle that references that compressed swap page.  This mapping is achi=
eved
>>  with a red-black tree per swap type.  The swap offset is the search key=
 for the
>>  tree nodes.
>> @@ -74,9 +87,11 @@ controlled policy:
>>  * max_pool_percent - The maximum percentage of memory that the compress=
ed
>>      pool can occupy.
>>
>> -Zswap allows the compressor to be selected at kernel boot time by setti=
ng the
>> -=E2=80=9Ccompressor=E2=80=9D attribute.  The default compressor is lzo.=
  e.g.
>> -zswap.compressor=3Ddeflate
>> +The default compressor is lzo, but it can be selected at boot time by s=
etting
>> +the =E2=80=9Ccompressor=E2=80=9D attribute, e.g. zswap.compressor=3Dlzo=
.  It can also be changed
>> +at runtime using the sysfs "compressor" attribute, e.g.
>> +
>> +echo lzo > /sys/module/zswap/parameters/compressor
>
> Again, what happens to pages already compressed? Are they freed? Recompre=
ssed?

as above, they're kept.

> Does zswap remember it has to decompress them differently than the curren=
tly
> used compressor?

yep.  I'll update the doc.

thanks!

>
>>  A debugfs interface is provided for various statistic about pool size, =
number
>>  of pages stored, and various counters for the reasons pages are rejecte=
d.
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
