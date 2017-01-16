Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69F746B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:33:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so26230726wmi.6
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 23:33:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z80si11533128wmd.57.2017.01.15.23.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 15 Jan 2017 23:33:18 -0800 (PST)
Date: Mon, 16 Jan 2017 08:33:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170116073310.GA7981@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <20170114105632.GV20392@mtr-leonro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114105632.GV20392@mtr-leonro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org

On Sat 14-01-17 12:56:32, Leon Romanovsky wrote:
[...]
> Hi Michal,
> 
> I don't see mlx5_vzalloc in the changed list. Any reason why did you skip it?
> 
>  881 static inline void *mlx5_vzalloc(unsigned long size)
>  882 {
>  883         void *rtn;
>  884
>  885         rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
>  886         if (!rtn)
>  887                 rtn = vzalloc(size);
>  888         return rtn;
>  889 }

No reason to skip it, I just didn't see it. I will fold the following in
if you are OK with it
---
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index cdd2bd62f86d..5e6063170e48 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -874,12 +874,7 @@ static inline u16 cmdif_rev(struct mlx5_core_dev *dev)
 
 static inline void *mlx5_vzalloc(unsigned long size)
 {
-	void *rtn;
-
-	rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
-	if (!rtn)
-		rtn = vzalloc(size);
-	return rtn;
+	return kvzalloc(GFP_KERNEL, size);
 }
 
 static inline u32 mlx5_base_mkey(const u32 key)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
