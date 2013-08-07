Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 8C5D76B00E9
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 09:58:22 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id 15so1816811vea.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 06:58:21 -0700 (PDT)
Date: Wed, 7 Aug 2013 09:58:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] memcg: limit the number of thresholds per-memcg
Message-ID: <20130807135818.GG27006@htj.dyndns.org>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <20130807132210.GD27006@htj.dyndns.org>
 <20130807134654.GJ8184@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807134654.GJ8184@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

Hello,

On Wed, Aug 07, 2013 at 03:46:54PM +0200, Michal Hocko wrote:
> OK, I have obviously misunderstood your concern mentioned in the other
> email. Could you be more specific what is the DoS scenario which was
> your concern, then?

So, let's say the file is write-accessible to !priv user which is
under reasonable resource limits.  Normally this shouldn't affect priv
system tools which are monitoring the same event as it shouldn't be
able to deplete resources as long as the resource control mechanisms
are configured and functioning properly; however, the memory usage
event puts all event listeners into a single contiguous table which a
!priv user can easily expand to a size where the table can no longer
be enlarged and if a priv system tool or another user tries to
register event afterwards, it'll fail.  IOW, it creates a shared
resource which isn't properly provisioned and can be trivially filled
up making it an easy DoS target.

Putting an extra limit on it isn't an actual solution but could be
better, I think.  It at least makes it clear that this is a limited
global resource.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
