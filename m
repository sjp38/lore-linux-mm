Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id EB92A6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 22:17:55 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id f11so1912111qae.17
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:17:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o92si2529259qgd.7.2014.03.13.19.17.55
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 19:17:55 -0700 (PDT)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2E2Hr3x023986
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 22:17:54 -0400
Received: from gelk.kernelslacker.org (ovpn-113-167.phx2.redhat.com [10.3.113.167])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s2E2Hluk006852
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 22:17:52 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.8/8.14.7) with ESMTP id s2E2HkQp005055
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 22:17:46 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.8/8.14.8/Submit) id s2E2HjPW005054
	for linux-mm@kvack.org; Thu, 13 Mar 2014 22:17:45 -0400
Date: Thu, 13 Mar 2014 22:17:45 -0400
From: Dave Jones <davej@redhat.com>
Subject: non-atomic rss_stat modifications
Message-ID: <20140314021745.GA4894@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I've been trying to make sense of this message which I keep seeing..

BUG: Bad rss-counter state mm:ffff88018bb78000 idx:0 val:1

Looking at the FILEPAGES counter accesses...

$ rgrep FILEPAGES mm
mm/filemap_xip.c:			dec_mm_counter(mm, MM_FILEPAGES);
mm/oom_kill.c:		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
mm/fremap.c:			dec_mm_counter(mm, MM_FILEPAGES);
mm/memory.c:					rss[MM_FILEPAGES]++;
mm/memory.c:			rss[MM_FILEPAGES]++;
mm/memory.c:				rss[MM_FILEPAGES]--;
mm/memory.c:					rss[MM_FILEPAGES]--;
mm/memory.c:	inc_mm_counter_fast(mm, MM_FILEPAGES);
mm/memory.c:				dec_mm_counter_fast(mm, MM_FILEPAGES);
mm/memory.c:			inc_mm_counter_fast(mm, MM_FILEPAGES);
mm/rmap.c:				dec_mm_counter(mm, MM_FILEPAGES);
mm/rmap.c:		dec_mm_counter(mm, MM_FILEPAGES);
mm/rmap.c:		dec_mm_counter(mm, MM_FILEPAGES);


How come we sometimes use the atomic accessors, but in copy_one_pte() and
zap_pte_range() we don't ?  Is that safe ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
