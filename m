Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBE66B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 05:56:44 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so8471125qga.22
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 02:56:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f13si27697902qaa.110.2014.08.04.02.56.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 02:56:43 -0700 (PDT)
Message-ID: <53DF58CA.5040807@redhat.com>
Date: Mon, 04 Aug 2014 11:56:26 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg, vmscan: Fix forced scan of anonymous pages
References: <1406807385-5168-1-git-send-email-jmarchan@redhat.com> <1406807385-5168-3-git-send-email-jmarchan@redhat.com> <20140731123026.GE13561@dhcp22.suse.cz> <20140801184525.GK9952@cmpxchg.org> <20140801185251.GA31417@dhcp22.suse.cz>
In-Reply-To: <20140801185251.GA31417@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="sWaQuwtFLxuSNcU7mRdWHsdRknOxaJgkM"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sWaQuwtFLxuSNcU7mRdWHsdRknOxaJgkM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/01/2014 08:52 PM, Michal Hocko wrote:
> On Fri 01-08-14 14:45:25, Johannes Weiner wrote:
>> On Thu, Jul 31, 2014 at 02:30:26PM +0200, Michal Hocko wrote:
>>> On Thu 31-07-14 13:49:45, Jerome Marchand wrote:
>>>> @@ -1950,8 +1950,11 @@ static void get_scan_count(struct lruvec *lru=
vec, int swappiness,
>>>>  	 */
>>>>  	if (global_reclaim(sc)) {
>>>>  		unsigned long free =3D zone_page_state(zone, NR_FREE_PAGES);
>>>> +		unsigned long zonefile =3D
>>>> +			zone_page_state(zone, NR_LRU_BASE + LRU_ACTIVE_FILE) +
>>>> +			zone_page_state(zone, NR_LRU_BASE + LRU_INACTIVE_FILE);
>>>> =20
>>>> -		if (unlikely(file + free <=3D high_wmark_pages(zone))) {
>>>> +		if (unlikely(zonefile + free <=3D high_wmark_pages(zone))) {
>>>>  			scan_balance =3D SCAN_ANON;
>>>>  			goto out;
>>>>  		}
>>>
>>> You could move file and anon further down when we actually use them.

I missed that comment. Thanks for the cleanup Johannes!

>>
>> Agreed with that.  Can we merge this into the original patch?
>>
>> ---
>> From e49bef8d2751d9b27f1733e3e0eced325ffce700 Mon Sep 17 00:00:00 2001=

>> From: Johannes Weiner <hannes@cmpxchg.org>
>> Date: Fri, 1 Aug 2014 10:48:26 -0400
>> Subject: [patch] memcg, vmscan: Fix forced scan of anonymous pages fix=
 -
>>  cleanups
>>
>> o Use enum zone_stat_item symbols directly to select zone stats,
>>   rather than NR_LRU_BASE plus LRU index
>>
>> o scanned/rotated scaling is the only user of the lruvec anon/file
>>   counters, so move the reads of those values to right before that
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
> Yes, please.
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

>=20
> Thanks!
>=20
>> ---
>>  mm/vmscan.c | 23 +++++++++++++----------
>>  1 file changed, 13 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index b3f629bdf4fe..2836b5373b2e 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1934,11 +1934,6 @@ static void get_scan_count(struct lruvec *lruve=
c, int swappiness,
>>  		goto out;
>>  	}
>> =20
>> -	anon  =3D get_lru_size(lruvec, LRU_ACTIVE_ANON) +
>> -		get_lru_size(lruvec, LRU_INACTIVE_ANON);
>> -	file  =3D get_lru_size(lruvec, LRU_ACTIVE_FILE) +
>> -		get_lru_size(lruvec, LRU_INACTIVE_FILE);
>> -
>>  	/*
>>  	 * Prevent the reclaimer from falling into the cache trap: as
>>  	 * cache pages start out inactive, every cache fault will tip
>> @@ -1949,12 +1944,14 @@ static void get_scan_count(struct lruvec *lruv=
ec, int swappiness,
>>  	 * anon pages.  Try to detect this based on file LRU size.
>>  	 */
>>  	if (global_reclaim(sc)) {
>> -		unsigned long free =3D zone_page_state(zone, NR_FREE_PAGES);
>> -		unsigned long zonefile =3D
>> -			zone_page_state(zone, NR_LRU_BASE + LRU_ACTIVE_FILE) +
>> -			zone_page_state(zone, NR_LRU_BASE + LRU_INACTIVE_FILE);
>> +		unsigned long zonefile;
>> +		unsigned long zonefree;
>> +
>> +		zonefree =3D zone_page_state(zone, NR_FREE_PAGES);
>> +		zonefile =3D zone_page_state(zone, NR_ACTIVE_FILE) +
>> +			   zone_page_state(zone, NR_INACTIVE_FILE);
>> =20
>> -		if (unlikely(zonefile + free <=3D high_wmark_pages(zone))) {
>> +		if (unlikely(zonefile + zonefree <=3D high_wmark_pages(zone))) {
>>  			scan_balance =3D SCAN_ANON;
>>  			goto out;
>>  		}
>> @@ -1989,6 +1986,12 @@ static void get_scan_count(struct lruvec *lruve=
c, int swappiness,
>>  	 *
>>  	 * anon in [0], file in [1]
>>  	 */
>> +
>> +	anon  =3D get_lru_size(lruvec, LRU_ACTIVE_ANON) +
>> +		get_lru_size(lruvec, LRU_INACTIVE_ANON);
>> +	file  =3D get_lru_size(lruvec, LRU_ACTIVE_FILE) +
>> +		get_lru_size(lruvec, LRU_INACTIVE_FILE);
>> +
>>  	spin_lock_irq(&zone->lru_lock);
>>  	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
>>  		reclaim_stat->recent_scanned[0] /=3D 2;
>> --=20
>> 2.0.3
>>
>=20



--sWaQuwtFLxuSNcU7mRdWHsdRknOxaJgkM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT31jKAAoJEHTzHJCtsuoCsLYH+wT9LBc/khDWN8S5zvWxMe56
XCrJna3N7eTNJd6afBKmyUUoHlMWQsq+AYTTsVaniKDfW1a3BePFAkfQ2DT6N6Af
TRcVdApQe6gwntZ0ryPcG34Fb/RIYJZaaV0rLs011kp2U0I19sBBuvsDR0HZ+Yyj
rlL7PoJujkMP6LN62pKA368uaztjQDdY6USt5HcdLcod9dfDeSixlpZkW9tMhLp/
f1ceZCYpprT1HgApWzsJuZXX5uGx1b9eKBNn85DpfVhm/JdqupclScyHOadQfNA/
j2GtET4XDdcpJ8eHqigP9+8gMItO+RWEWXzpIgDuc6WKhGc3PznpjRLc1JF5ZvU=
=H74y
-----END PGP SIGNATURE-----

--sWaQuwtFLxuSNcU7mRdWHsdRknOxaJgkM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
