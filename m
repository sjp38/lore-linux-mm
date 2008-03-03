Received: by ik-out-1112.google.com with SMTP id c28so5213110ika.6
        for <linux-mm@kvack.org>; Mon, 03 Mar 2008 03:02:52 -0800 (PST)
Message-ID: <47CBD7E3.4020500@gmail.com>
Date: Mon, 03 Mar 2008 19:50:11 +0900
MIME-Version: 1.0
Subject: Re: [patch 07/21] SEQ replacement for anonymous pages
References: <20080228192908.126720629@redhat.com> <20080228192928.492644028@redhat.com>
In-Reply-To: <20080228192928.492644028@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
From: "barrioskmc@gmail" <minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Rik.

static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
  				struct scan_control *sc, int priority, int file)
  {
-	unsigned long pgmoved;
+	unsigned long pgmoved = 0;
  	int pgdeactivate = 0;
  	unsigned long pgscanned;
  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
@@ -1058,12 +1058,25 @@ static void shrink_active_list(unsigned
  		cond_resched();
  		page = lru_to_page(&l_hold);
  		list_del(&page->lru);
-		if (page_referenced(page, 0, sc->mem_cgroup))
-			lru = LRU_ACTIVE_ANON;
+		if (page_referenced(page, 0, sc->mem_cgroup)) {
+			if (file)
+				/* Referenced file pages stay active. */
+				lru = LRU_ACTIVE_ANON;
+			else
+				/* Anonymous pages always get deactivated. */
+				pgmoved++;
+		}
  		list_add(&page->lru, &list[lru]);
  	}

Why do you insert referenced page to LRU_ACTIVE_ANON ?
I have seen picture in your design document 
(http://linux-mm.org/PageReplacementDesign)
If I understand your point well, page referenced is inserted to 
LRU_ACTIVE_FILE.

What am I missing in your point?

Thanks, barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
