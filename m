Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EF6F35F0001
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 02:28:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3I6SwlG009775
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 18 Apr 2009 15:28:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF2345DD81
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:28:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 37E3445DD7E
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:28:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0204FE08006
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:28:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B821DB803B
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:28:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: + mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char.patch added to -mm tree
In-Reply-To: <200904150009.n3F095J1011993@imap1.linux-foundation.org>
References: <200904150009.n3F095J1011993@imap1.linux-foundation.org>
Message-Id: <20090418152635.125D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sat, 18 Apr 2009 15:28:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, den@openvz.org, dwmw2@infradead.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/mtd/mtdcore.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff -puN drivers/mtd/mtdcore.c~mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char drivers/mtd/mtdcore.c
> --- a/drivers/mtd/mtdcore.c~mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char
> +++ a/drivers/mtd/mtdcore.c
> @@ -48,11 +48,11 @@ static LIST_HEAD(mtd_notifiers);
>   */
>  static void mtd_release(struct device *dev)
>  {
> -	struct mtd_info *mtd = dev_to_mtd(dev);
> +	dev_t index = MTD_DEVT(dev_to_mtd(dev));
>  
>  	/* remove /dev/mtdXro node if needed */
> -	if (MTD_DEVT(mtd->index))
> -		device_destroy(mtd_class, MTD_DEVT(mtd->index) + 1);
> +	if (index)
> +		device_destroy(mtd_class, index + 1);
>  }

I get compile failure problem on mmotm-0414.

=====================
mtd-mtd-in-mtd_release-is-unused-without-config_mtd_char.patch remove one
warnig if CONFIG_MTD_CHAR=n.

but it introduce one compile error if CONFIG_MTD_CHAR=y/m.

    drivers/mtd/mtdcore.c: In function ‘mtd_release’:
    drivers/mtd/mtdcore.c:51: error: invalid operands to binary * (have ‘struct mtd_info *’ and ‘int’)



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Denis V. Lunev <den@openvz.org>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 drivers/mtd/mtdcore.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/drivers/mtd/mtdcore.c
===================================================================
--- a/drivers/mtd/mtdcore.c	2009-04-16 21:43:18.000000000 +0900
+++ b/drivers/mtd/mtdcore.c	2009-04-16 21:44:23.000000000 +0900
@@ -48,7 +48,7 @@ static LIST_HEAD(mtd_notifiers);
  */
 static void mtd_release(struct device *dev)
 {
-	dev_t index = MTD_DEVT(dev_to_mtd(dev));
+	dev_t index = MTD_DEVT(dev_to_mtd(dev)->index);
 
 	/* remove /dev/mtdXro node if needed */
 	if (index)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
