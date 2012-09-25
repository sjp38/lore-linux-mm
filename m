Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A15046B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 19:31:21 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <30a570e8-8157-47e1-867a-4960a7c1173d@default>
Date: Tue, 25 Sep 2012 16:31:01 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH] zcache2 on PPC64 (Was: [RFC] mm: add support for zsmalloc
 and zcache)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

Attached patch applies to staging-next and I _think_ should
fix the reported problem where zbud in zcache2 does not
work on a PPC64 with PAGE_SIZE!=3D12.  I do not have a machine
to test this so testing by others would be appreciated.

Ideally there should also be a BUILD_BUG_ON to ensure
PAGE_SHIFT * 2 + 2 doesn't exceed BITS_PER_LONG, but
let's see if this fixes the problem first.

Apologies if there are line breaks... I can't send this from
a linux mailer right now.  If it is broken, let me know,
and I will re-post tomorrow... though it should be easy
to apply manually for test purposes.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diff --git a/drivers/staging/ramster/zbud.c b/drivers/staging/ramster/zbud.=
c
index a7c4361..6921af3 100644
--- a/drivers/staging/ramster/zbud.c
+++ b/drivers/staging/ramster/zbud.c
@@ -103,8 +103,8 @@ struct zbudpage {
 =09=09struct {
 =09=09=09unsigned long space_for_flags;
 =09=09=09struct {
-=09=09=09=09unsigned zbud0_size:12;
-=09=09=09=09unsigned zbud1_size:12;
+=09=09=09=09unsigned zbud0_size:PAGE_SHIFT;
+=09=09=09=09unsigned zbud1_size:PAGE_SHIFT;
 =09=09=09=09unsigned unevictable:2;
 =09=09=09};
 =09=09=09struct list_head budlist;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
