Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 4C3EA6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 21:25:10 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so1160054pbb.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 18:25:09 -0700 (PDT)
Date: Wed, 26 Sep 2012 06:55:03 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: [PATCH 1/5] mm/readahead: Check return value of read_pages
Message-ID: <20120926012503.GA24218@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <dcdfd8620ae632321a28112f5074cc3c78d05bde.1348309711.git.rprabhu@wnohang.net>
 <20120922124337.GA17562@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Content-Disposition: inline
In-Reply-To: <20120922124337.GA17562@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

=20
Hi,


* On Sat, Sep 22, 2012 at 08:43:37PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Sat, Sep 22, 2012 at 04:03:10PM +0530, raghu.prabhu13@gmail.com wrote:
>> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>
>> Return value of a_ops->readpage will be propagated to return value of re=
ad_pages
>> and __do_page_cache_readahead.
>
>That does not explain the intention and benefit of this patch..

I noticed that force_page_cache_readahead checks return value of=20
__do_page_cache_readahead but the actual error if any is never=20
propagated.


Also, I made a slight change there:


+	int alloc =3D 1;
 =20
  	blk_start_plug(&plug);
 =20
@@ -127,13 +128,18 @@ static int read_pages(struct address_space *mapping, =
struct file *filp,
  	for (page_idx =3D 0; page_idx < nr_pages; page_idx++) {
  		struct page *page =3D list_to_page(pages);
  		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping,
+		if (alloc && !add_to_page_cache_lru(page, mapping,
  					page->index, GFP_KERNEL)) {
-			mapping->a_ops->readpage(filp, page);
+			ret =3D mapping->a_ops->readpage(filp, page);
+			/*=20
+			 * If readpage fails, don't proceed with further
+			 * readpage
+			 * */
+			if (ret < 0)
+				alloc =3D 0;

Before, this the page_cache_release was not happening for the=20
rest of the pages.

I will send it in separate patch if this is fine.

>
>Thanks,
>Fengguang
>
>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> ---
>>  mm/readahead.c | 12 +++++++-----
>>  1 file changed, 7 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/readahead.c b/mm/readahead.c
>> index ea8f8fa..461fcc0 100644
>> --- a/mm/readahead.c
>> +++ b/mm/readahead.c
>> @@ -113,7 +113,7 @@ static int read_pages(struct address_space *mapping,=
 struct file *filp,
>>  {
>>  	struct blk_plug plug;
>>  	unsigned page_idx;
>> -	int ret;
>> +	int ret =3D 0;
>>
>>  	blk_start_plug(&plug);
>>
>> @@ -129,11 +129,12 @@ static int read_pages(struct address_space *mappin=
g, struct file *filp,
>>  		list_del(&page->lru);
>>  		if (!add_to_page_cache_lru(page, mapping,
>>  					page->index, GFP_KERNEL)) {
>> -			mapping->a_ops->readpage(filp, page);
>> +			ret =3D mapping->a_ops->readpage(filp, page);
>> +			if (ret < 0)
>> +				break;
>>  		}
>>  		page_cache_release(page);
>>  	}
>> -	ret =3D 0;
>>
>>  out:
>>  	blk_finish_plug(&plug);
>> @@ -160,6 +161,7 @@ __do_page_cache_readahead(struct address_space *mapp=
ing, struct file *filp,
>>  	LIST_HEAD(page_pool);
>>  	int page_idx;
>>  	int ret =3D 0;
>> +	int ret_read =3D 0;
>>  	loff_t isize =3D i_size_read(inode);
>>
>>  	if (isize =3D=3D 0)
>> @@ -198,10 +200,10 @@ __do_page_cache_readahead(struct address_space *ma=
pping, struct file *filp,
>>  	 * will then handle the error.
>>  	 */
>>  	if (ret)
>> -		read_pages(mapping, filp, &page_pool, ret);
>> +		ret_read =3D read_pages(mapping, filp, &page_pool, ret);
>>  	BUG_ON(!list_empty(&page_pool));
>>  out:
>> -	return ret;
>> +	return (ret_read < 0 ? ret_read : ret);
>>  }
>>
>>  /*
>> --
>> 1.7.12.1
>








Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--ReaqsoxgOBHFXBhH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQYllvAAoJEKYW3KHXK+l3LK8H/1YT5zdm3j2zJE3IDZ0at4pB
i8krRZKe6iK58A/SFqRQWx+7CD7c0r8zJejlwO8Pk8qA7Bk1PiESq2bFtp3WFg62
QHYdMCygO2ET67mWjwYOtgSXM6YnazE3xrwepcssB25+wzCZb5xesEQmo0P1au2J
mwjUKpYqpal1vBIU+wj+Acd8nOaHFw+ZMwAK3KB1zb4M6C6wMsmxokcXUZp2DeQy
elhMHy4jrqioD6YXZtCV6Bn8Hq4tAY3BgzhsN4521WluQ7Ps2FbFWdgwJlqEUXbw
seNc892lNvIdPAHbggE2bTJrlM7dqDkPZE5pxl5t5w9z51j0f2krSGWOpeC3WO8=
=jzZE
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
