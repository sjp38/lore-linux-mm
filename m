Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA516B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 15:36:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so483866wme.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 12:36:41 -0700 (PDT)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id f67si189310wmf.85.2016.06.17.12.36.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 12:36:40 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: Don't blindly assign fallback_migrate_page()
References: <1466112375-1717-1-git-send-email-richard@nod.at>
 <1466112375-1717-2-git-send-email-richard@nod.at>
 <20160616161121.35ee5183b9ef9f7b7dcbc815@linux-foundation.org>
 <5763A9B2.8060303@nod.at> <20160617162803.GK21670@dhcp22.suse.cz>
 <57642B91.4020206@nod.at> <20160617182751.GB692@dhcp22.suse.cz>
From: Richard Weinberger <richard@nod.at>
Message-ID: <5764513E.2070102@nod.at>
Date: Fri, 17 Jun 2016 21:36:30 +0200
MIME-Version: 1.0
In-Reply-To: <20160617182751.GB692@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, adrian.hunter@intel.com, dedekind1@gmail.com, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com



Am 17.06.2016 um 20:27 schrieb Michal Hocko:
> On Fri 17-06-16 18:55:45, Richard Weinberger wrote:
>> Am 17.06.2016 um 18:28 schrieb Michal Hocko:
>>> But doesn't this disable the page migration and so potentially reduce
>>> the compaction success rate for the large pile of filesystems? Without
>>> any hint about that?
>>
>> The WARN_ON_ONCE() is the hint. ;)
> 
> Right. My reply turned a different way than I meant... I meant to say
> that there might be different regressions caused by this change without much
> hint that a particular warning would be the smoking gun... 
> 

Okay, what about something like that?
That way everything works as before and we don't have regressions
but FS maintainers will notice the WARN_ON_ONCE() and hopefully review
whether generic_migrate_page() is really suitable.
If so, they can set their a_ops->migratepage to generic_migrate_page().

@@ -771,8 +773,15 @@ static int move_to_new_page(struct page *newpage, struct page *page,
                 * is the most common path for page migration.
                 */
                rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
-       else
-               rc = fallback_migrate_page(mapping, newpage, page, mode);
+       else {
+               /*
+                * Dear filesystem maintainer, please verify whether
+                * generic_migrate_page() is suitable for your
+                * filesystem, especially wrt. page flag handling.
+                */
+               WARN_ON_ONCE(1);
+               rc = generic_migrate_page(mapping, newpage, page, mode);
+       }

        /*
         * When successful, old pagecache page->mapping must be cleared before

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
