Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id ABE836B003C
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 10:48:18 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2241855pab.40
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 07:48:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id ei3si28010714pbc.80.2013.11.14.07.48.16
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 07:48:17 -0800 (PST)
Date: Thu, 14 Nov 2013 10:47:30 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1384444050-v86q6ypr-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131112115633.GA16700@pd.tnic>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130928172602.GA6191@pd.tnic>
 <1380553263-lqp3ggll-mutt-n-horiguchi@ah.jp.nec.com>
 <20130930160450.GA20030@pd.tnic>
 <1380557324-v44mpchd-mutt-n-horiguchi@ah.jp.nec.com>
 <20131112115633.GA16700@pd.tnic>
Subject: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()(Re:
 [PATCH 4/9] migrate: add hugepage migration code to move_pages())
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 12, 2013 at 12:56:33PM +0100, Borislav Petkov wrote:
> On Mon, Sep 30, 2013 at 12:08:44PM -0400, Naoya Horiguchi wrote:
> > On Mon, Sep 30, 2013 at 06:04:50PM +0200, Borislav Petkov wrote:
> > > On Mon, Sep 30, 2013 at 11:01:03AM -0400, Naoya Horiguchi wrote:
> > > > Thanks for reporting. The patch should fix this.
> > > > 
> > > > Naoya Horiguchi
> > > > ---
> > > > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > > Date: Mon, 30 Sep 2013 10:22:26 -0400
> > > > Subject: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()
> > > > 
> > > > Introduces a cosmetic substitution of the returned value of isolate_huge_page()
> > > > to suppress a build warning when !CONFIG_HUGETLBFS. No behavioral change.
> > > > 
> > > > Reported-by: Borislav Petkov <bp@alien8.de>
> > > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > 
> > > Thanks for this. Unfortunately, I cannot trigger it anymore. :\ Maybe it
> > > is because I pulled latest git and this was triggering only on a older
> > > repo state, hmmm.
> > > 
> > > The patch looks obviously correct though so you could send it up or hold
> > > on to it until someone else reports it.
> > > 
> > > Anyway, sorry for the trouble.
> > 
> > OK, no problem :)
> 
> Hey Naoya,
> 
> I can trigger this issue again.
> 
> Kernel is latest Linus: v3.12-4849-g10d0c9705e80
> 
> Compiler is: gcc (Debian 4.8.1-10) 4.8.1, config is attached.
> 
> And yes, the patch you sent me previously is still good and fixes the
> warning so feel free to add my Tested-by: tag.

Sorry for late response, and thanks for testing!
Andrew, can you apply this fix?

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 30 Sep 2013 10:22:26 -0400
Subject: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()

Introduces a cosmetic substitution of the returned value of isolate_huge_page()
to suppress a build warning when !CONFIG_HUGETLBFS. No behavioral change.

Reported-by: Borislav Petkov <bp@alien8.de>
Tested-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 4cd63c2..4a26042 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1168,7 +1168,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto put_and_set;
 
 		if (PageHuge(page)) {
-			isolate_huge_page(page, &pagelist);
+			err = isolate_huge_page(page, &pagelist);
 			goto put_and_set;
 		}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
