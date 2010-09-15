Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E0A986B007B
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 23:31:09 -0400 (EDT)
Date: Wed, 15 Sep 2010 11:31:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20100915033059.GA12542@localhost>
References: <20100915091118.3dbdc961@notabene>
 <4C90139A.1080809@redhat.com>
 <20100915122334.3fa7b35f@notabene>
 <20100915023735.GA9175@localhost>
 <20100915025454.GA10230@localhost>
 <20100915030640.GA11141@localhost>
 <20100915031343.GA12005@localhost>
 <1284520712.30133.1.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284520712.30133.1.camel@sli10-conroe.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 11:18:32AM +0800, Li, Shaohua wrote:

> > +	if (!(sc->gfp_mask & __GFP_WAIT))
> > +		return 0;
> > +
> it appears __GFP_WAIT allocation doesn't go to direct reclaim.

Good point! So we are returning to its very first version ;)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1135,6 +1135,7 @@ static int too_many_isolated(struct zone *zone, int file,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
+	int ratio;
 
 	if (current_is_kswapd())
 		return 0;
@@ -1150,7 +1151,9 @@ static int too_many_isolated(struct zone *zone, int file,
 		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
 	}
 
-	return isolated > inactive;
+	ratio = sc->gfp_mask & (__GFP_IO | __GFP_FS) ? 1 : 8;
+
+	return isolated > inactive * ratio;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
