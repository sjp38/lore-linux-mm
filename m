Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E2F0F6B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 22:55:42 -0400 (EDT)
Received: by iwn33 with SMTP id 33so33849iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 19:55:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100902091206.D053.A69D9226@jp.fujitsu.com>
References: <AANLkTinxHbeCUh80i515FPMpF-GY4S0kh9PHqUNtYP-m@mail.gmail.com>
	<20100901155644.GA10246@barrios-desktop>
	<20100902091206.D053.A69D9226@jp.fujitsu.com>
Date: Thu, 2 Sep 2010 11:55:40 +0900
Message-ID: <AANLkTiknTqHw11xRXNP4X-0yN1=rWyCh3MJV=HjRiZQJ@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] vmscan: don't use return value trick when oom_killer_disabled
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=0016e645b942107d50048f3df3a9
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--0016e645b942107d50048f3df3a9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 2, 2010 at 9:57 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Wed, Sep 01, 2010 at 11:01:43AM +0900, Minchan Kim wrote:
>> > On Wed, Sep 1, 2010 at 10:55 AM, KOSAKI Motohiro
>> > <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > > Hi
>> > >
>> > > Thank you for good commenting!
>> > >
>> > >
>> > >> I don't like use oom_killer_disabled directly.
>> > >> That's because we have wrapper inline functions to handle the
>> > >> variable(ex, oom_killer_[disable/enable]).
>> > >> It means we are reluctant to use the global variable directly.
>> > >> So should we make new function as is_oom_killer_disable?
>> > >>
>> > >> I think NO.
>> > >>
>> > >> As I read your description, this problem is related to only hiberna=
tion.
>> > >> Since hibernation freezes all processes(include kswapd), this probl=
em
>> > >> happens. Of course, now oom_killer_disabled is used by only
>> > >> hibernation. But it can be used others in future(Off-topic : I don'=
t
>> > >> want it). Others can use it without freezing processes. Then kswapd
>> > >> can set zone->all_unreclaimable and the problem can't happen.
>> > >>
>> > >> So I want to use sc->hibernation_mode which is already used
>> > >> do_try_to_free_pages instead of oom_killer_disabled.
>> > >
>> > > Unfortunatelly, It's impossible. shrink_all_memory() turn on
>> > > sc->hibernation_mode. but other hibernation caller merely call
>> > > alloc_pages(). so we don't have any hint.
>> > >
>> > Ahh.. True. Sorry for that.
>> > I will think some better method.
>> > if I can't find it, I don't mind this patch. :)
>>
>> It seems that the poblem happens following as.
>> (I might miss something since I just read theyour description)
>>
>> hibernation
>> oom_disable
>> alloc_pages
>> do_try_to_free_pages
>> =A0 =A0 =A0 =A0 if (scanning_global_lru(sc) && !all_unreclaimable)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> If kswapd is not freezed, it would set zone->all_unreclaimable to 1 and =
then
>> shrink_zones maybe return true. so alloc_pages could go to _nopage_.
>> If it is, it's no problem.
>> Right?
>>
>> I think the problem would come from shrink_zones.
>> It set false to all_unreclaimable blindly even though shrink_zone can't =
reclaim
>> any page. It doesn't make sense.
>> How about this?
>> I think we need this regardless of the problem.
>> What do you think about?
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index d8fd87d..22017b3 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1901,7 +1901,8 @@ static bool shrink_zones(int priority, struct zone=
list *zonelist,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 all_unreclaimable =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc->nr_reclaimed)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 all_unreclaimable =3D fals=
e;
>> =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 return all_unreclaimable;
>> =A0}
>
> here is brief of shrink_zones().
>
> =A0 =A0 =A0 =A0for_each_zone_zonelist_nodemask(zone, z, zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_zone(sc->gfp_mask), sc->nodemask) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!populated_zone(zone))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (zone->all_unreclaimable && priority !=
=3D DEF_PRIORITY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue; =A0 =A0 =
=A0 /* Let kswapd poll it */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone(priority, zone, sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0all_unreclaimable =3D false;
> =A0 =A0 =A0 =A0}
>
> That said,
> =A0 =A0 =A0 =A0all zone's zone->all_unreclaimable are true
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-> all_unreclaimable local variable become=
 true.
> =A0 =A0 =A0 =A0otherwise
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-> all_unreclaimable local variable become=
 false.
>
> The intention is, we don't want to invoke oom-killer if there are
> !all_unreclaimable zones. So your patch makes big design change and
> seems to increase OOM risk.

Right. Thanks for pointing me out.

> I don't want to send risky patch to -stable.

Still I don't want to use oom_killer_disabled magic.
But I don't want to prevent urgent stable patch due to my just nitpick.

This is my last try(just quick patch, even I didn't tried compile test).
If this isn't good, first of all, let's try merge yours.
And then we can fix it later.

Thanks for comment.

-- CUT HERE --

Why do we check zone->all_unreclaimable in only kswapd?
If kswapd is freezed in hibernation, OOM can happen.
Let's the check in direct reclaim path, too.


diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3109ff7..41493ba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1878,12 +1878,11 @@ static void shrink_zone(int priority, struct zone *=
zone,
 * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static bool shrink_zones(int priority, struct zonelist *zonelist,
+static void shrink_zones(int priority, struct zonelist *zonelist,
                                        struct scan_control *sc)
 {
        struct zoneref *z;
        struct zone *zone;
-       bool all_unreclaimable =3D true;

        for_each_zone_zonelist_nodemask(zone, z, zonelist,
                                        gfp_zone(sc->gfp_mask), sc->nodemas=
k) {
@@ -1901,8 +1900,25 @@ static bool shrink_zones(int priority, struct
zonelist *zonelist,
                }

                shrink_zone(priority, zone, sc);
-               all_unreclaimable =3D false;
        }
+}
+
+static inline int all_unreclaimable(struct zonelist *zonelist, struct
scan_control *sc)
+{
+       struct zoneref *z;
+       struct zone *zone;
+       bool all_unreclaimable =3D true;
+
+       for_each_zone_zonelist_nodemask(zone, z, zonelist,
+                                       gfp_zone(sc->gfp_mask), sc->nodemas=
k) {
+               if (!populated_zone(zone))
+                       continue;
+               if (zone->pages_scanned < (zone_reclaimable_pages(zone) * 6=
)) {
+                       all_unreclaimable =3D false;
+                       break;
+               }
+       }
+
        return all_unreclaimable;
 }

@@ -1926,7 +1942,6 @@ static unsigned long do_try_to_free_pages(struct
zonelist *zonelist,
                                        struct scan_control *sc)
 {
        int priority;
-       bool all_unreclaimable;
        unsigned long total_scanned =3D 0;
        struct reclaim_state *reclaim_state =3D current->reclaim_state;
        struct zoneref *z;
@@ -1943,7 +1958,7 @@ static unsigned long do_try_to_free_pages(struct
zonelist *zonelist,
                sc->nr_scanned =3D 0;
                if (!priority)
                        disable_swap_token();
-               all_unreclaimable =3D shrink_zones(priority, zonelist, sc);
+               shrink_zones(priority, zonelist, sc);
                /*
                 * Don't shrink slabs when reclaiming memory from
                 * over limit cgroups
@@ -2005,7 +2020,7 @@ out:
                return sc->nr_reclaimed;

        /* top priority shrink_zones still had more to do? don't OOM, then =
*/
-       if (scanning_global_lru(sc) && !all_unreclaimable)
+       if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
                return 1;

        return 0;


--=20
Kind regards,
Minchan Kim

--0016e645b942107d50048f3df3a9
Content-Type: text/x-diff; charset=US-ASCII; name="all_unreclaimable.patch"
Content-Disposition: attachment; filename="all_unreclaimable.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gdl0e0bn0

ZGlmZiAtLWdpdCBhL21tL3Ztc2Nhbi5jIGIvbW0vdm1zY2FuLmMKaW5kZXggMzEwOWZmNy4uNDE0
OTNiYSAxMDA2NDQKLS0tIGEvbW0vdm1zY2FuLmMKKysrIGIvbW0vdm1zY2FuLmMKQEAgLTE4Nzgs
MTIgKzE4NzgsMTEgQEAgc3RhdGljIHZvaWQgc2hyaW5rX3pvbmUoaW50IHByaW9yaXR5LCBzdHJ1
Y3Qgem9uZSAqem9uZSwKICAqIElmIGEgem9uZSBpcyBkZWVtZWQgdG8gYmUgZnVsbCBvZiBwaW5u
ZWQgcGFnZXMgdGhlbiBqdXN0IGdpdmUgaXQgYSBsaWdodAogICogc2NhbiB0aGVuIGdpdmUgdXAg
b24gaXQuCiAgKi8KLXN0YXRpYyBib29sIHNocmlua196b25lcyhpbnQgcHJpb3JpdHksIHN0cnVj
dCB6b25lbGlzdCAqem9uZWxpc3QsCitzdGF0aWMgdm9pZCBzaHJpbmtfem9uZXMoaW50IHByaW9y
aXR5LCBzdHJ1Y3Qgem9uZWxpc3QgKnpvbmVsaXN0LAogCQkJCQlzdHJ1Y3Qgc2Nhbl9jb250cm9s
ICpzYykKIHsKIAlzdHJ1Y3Qgem9uZXJlZiAqejsKIAlzdHJ1Y3Qgem9uZSAqem9uZTsKLQlib29s
IGFsbF91bnJlY2xhaW1hYmxlID0gdHJ1ZTsKIAogCWZvcl9lYWNoX3pvbmVfem9uZWxpc3Rfbm9k
ZW1hc2soem9uZSwgeiwgem9uZWxpc3QsCiAJCQkJCWdmcF96b25lKHNjLT5nZnBfbWFzayksIHNj
LT5ub2RlbWFzaykgewpAQCAtMTkwMSw4ICsxOTAwLDI1IEBAIHN0YXRpYyBib29sIHNocmlua196
b25lcyhpbnQgcHJpb3JpdHksIHN0cnVjdCB6b25lbGlzdCAqem9uZWxpc3QsCiAJCX0KIAogCQlz
aHJpbmtfem9uZShwcmlvcml0eSwgem9uZSwgc2MpOwotCQlhbGxfdW5yZWNsYWltYWJsZSA9IGZh
bHNlOwogCX0KK30KKworc3RhdGljIGlubGluZSBpbnQgYWxsX3VucmVjbGFpbWFibGUoc3RydWN0
IHpvbmVsaXN0ICp6b25lbGlzdCwgc3RydWN0IHNjYW5fY29udHJvbCAqc2MpCit7CisJc3RydWN0
IHpvbmVyZWYgKno7CisJc3RydWN0IHpvbmUgKnpvbmU7CisJYm9vbCBhbGxfdW5yZWNsYWltYWJs
ZSA9IHRydWU7CisKKwlmb3JfZWFjaF96b25lX3pvbmVsaXN0X25vZGVtYXNrKHpvbmUsIHosIHpv
bmVsaXN0LAorCQkJCQlnZnBfem9uZShzYy0+Z2ZwX21hc2spLCBzYy0+bm9kZW1hc2spIHsKKwkJ
aWYgKCFwb3B1bGF0ZWRfem9uZSh6b25lKSkKKwkJCWNvbnRpbnVlOworCQlpZiAoem9uZS0+cGFn
ZXNfc2Nhbm5lZCA8ICh6b25lX3JlY2xhaW1hYmxlX3BhZ2VzKHpvbmUpICogNikpIHsKKwkJCWFs
bF91bnJlY2xhaW1hYmxlID0gZmFsc2U7CisJCQlicmVhazsKKwkJfQorCX0KKwogCXJldHVybiBh
bGxfdW5yZWNsYWltYWJsZTsKIH0KIApAQCAtMTkyNiw3ICsxOTQyLDYgQEAgc3RhdGljIHVuc2ln
bmVkIGxvbmcgZG9fdHJ5X3RvX2ZyZWVfcGFnZXMoc3RydWN0IHpvbmVsaXN0ICp6b25lbGlzdCwK
IAkJCQkJc3RydWN0IHNjYW5fY29udHJvbCAqc2MpCiB7CiAJaW50IHByaW9yaXR5OwotCWJvb2wg
YWxsX3VucmVjbGFpbWFibGU7CiAJdW5zaWduZWQgbG9uZyB0b3RhbF9zY2FubmVkID0gMDsKIAlz
dHJ1Y3QgcmVjbGFpbV9zdGF0ZSAqcmVjbGFpbV9zdGF0ZSA9IGN1cnJlbnQtPnJlY2xhaW1fc3Rh
dGU7CiAJc3RydWN0IHpvbmVyZWYgKno7CkBAIC0xOTQzLDcgKzE5NTgsNyBAQCBzdGF0aWMgdW5z
aWduZWQgbG9uZyBkb190cnlfdG9fZnJlZV9wYWdlcyhzdHJ1Y3Qgem9uZWxpc3QgKnpvbmVsaXN0
LAogCQlzYy0+bnJfc2Nhbm5lZCA9IDA7CiAJCWlmICghcHJpb3JpdHkpCiAJCQlkaXNhYmxlX3N3
YXBfdG9rZW4oKTsKLQkJYWxsX3VucmVjbGFpbWFibGUgPSBzaHJpbmtfem9uZXMocHJpb3JpdHks
IHpvbmVsaXN0LCBzYyk7CisJCXNocmlua196b25lcyhwcmlvcml0eSwgem9uZWxpc3QsIHNjKTsK
IAkJLyoKIAkJICogRG9uJ3Qgc2hyaW5rIHNsYWJzIHdoZW4gcmVjbGFpbWluZyBtZW1vcnkgZnJv
bQogCQkgKiBvdmVyIGxpbWl0IGNncm91cHMKQEAgLTIwMDUsNyArMjAyMCw3IEBAIG91dDoKIAkJ
cmV0dXJuIHNjLT5ucl9yZWNsYWltZWQ7CiAKIAkvKiB0b3AgcHJpb3JpdHkgc2hyaW5rX3pvbmVz
IHN0aWxsIGhhZCBtb3JlIHRvIGRvPyBkb24ndCBPT00sIHRoZW4gKi8KLQlpZiAoc2Nhbm5pbmdf
Z2xvYmFsX2xydShzYykgJiYgIWFsbF91bnJlY2xhaW1hYmxlKQorCWlmIChzY2FubmluZ19nbG9i
YWxfbHJ1KHNjKSAmJiAhYWxsX3VucmVjbGFpbWFibGUoem9uZWxpc3QsIHNjKSkKIAkJcmV0dXJu
IDE7CiAKIAlyZXR1cm4gMDsK
--0016e645b942107d50048f3df3a9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
