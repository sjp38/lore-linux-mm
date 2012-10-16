Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C279C6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 13:42:58 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so6958615pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 10:42:58 -0700 (PDT)
Date: Tue, 16 Oct 2012 23:12:52 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: Re: [PATCH 2/5] mm/readahead: Change the condition for
 SetPageReadahead
Message-ID: <20121016174252.GB2826@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
 <20120922124920.GB17562@localhost>
 <20120926012900.GA36532@Archie>
 <20120928115623.GB1525@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oJ71EGRlYNjSvfq7"
Content-Disposition: inline
In-Reply-To: <20120928115623.GB1525@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--oJ71EGRlYNjSvfq7
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Fri, Sep 28, 2012 at 07:56:23PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Wed, Sep 26, 2012 at 06:59:00AM +0530, Raghavendra D Prabhu wrote:
>> Hi,
>>
>>
>> * On Sat, Sep 22, 2012 at 08:49:20PM +0800, Fengguang Wu <fengguang.wu@i=
ntel.com> wrote:
>> >On Sat, Sep 22, 2012 at 04:03:11PM +0530, raghu.prabhu13@gmail.com wrot=
e:
>> >>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> >>
>> >>If page lookup from radix_tree_lookup is successful and its index page=
_idx =3D=3D
>> >>nr_to_read - lookahead_size, then SetPageReadahead never gets called, =
so this
>> >>fixes that.
>> >
>> >NAK. Sorry. It's actually an intentional behavior, so that for the
>> >common cases of many cached files that are accessed frequently, no
>> >PG_readahead will be set at all to pointlessly trap into the readahead
>> >routines once and again.
>>
>> ACK, thanks for explaining that. However, regarding this, I would
>> like to know if the implications of the patch
>> 51daa88ebd8e0d437289f589af29d4b39379ea76 will still apply if
>> PG_readahead is not set.
>
>Would you elaborate the implication and the possible problematic case?

Certainly.


An implication of 51daa88ebd8e0d437289f589af29d4b39379ea76 is=20
that, a redundant check for PageReadahead(page) is avoided since =20
async is piggy-backed into the synchronous readahead itself.


So, in case of=20

     page =3D find_get_page()
     if(!page)
         page_cache_sync_readahead()
     else if (PageReadahead(page))
         page_cache_async_readahead();

isnt' there a possibility that PG_readahead won't be set at all=20
if page is not in cache (causing page_cache_sync_readahead) but=20
page at index  (nr_to_read - lookahead_size) is already in the=20
cache? (due to if (page) continue; in the code)?


Hence, I changed the condition from equality to >=3D for setting=20
SetPageReadahead(page) (and added a=20
variable so that it is done only once).=20


>
>Thanks,
>Fengguang
>




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--oJ71EGRlYNjSvfq7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQfZycAAoJEKYW3KHXK+l3QTYH/A2DR0/+sp681eKa7pGGY2Ld
Te3yPiKJ0mixgXjw8hciTlFttr8CVvkowdlHwXRy2xKHwBkCQcJwHyFtTmfcn7pP
u753jXFIyw4QTi+rRWp3kcuan5d9WMg+U1i94oVeV+UFFCkxTNBQbZeucWrX+BBU
tcXbIttfa+zw7xmtfySZb11xpC6/dUlydsd1AbxtIQV82btrEmfWULlGHUcMhQvI
viSf7slZ8jVAm59Nf6MWmCjZ4DN4rXH8vQrSCR8EzD+ESLSppfX7mlxaCJn5/0Ci
hn9sQFT6DcdEVzUeLB2x2kufL+uwwkK/xGDt+2V6X1RAK44FuFaR72Eov71kUIQ=
=DoFM
-----END PGP SIGNATURE-----

--oJ71EGRlYNjSvfq7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
