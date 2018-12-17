Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67E968E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:51:36 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id i124so8037058pgc.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 02:51:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 187si11953702pfb.41.2018.12.17.02.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 02:51:34 -0800 (PST)
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
 <20181217093337.GC30879@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
Date: Mon, 17 Dec 2018 19:51:27 +0900
MIME-Version: 1.0
In-Reply-To: <20181217093337.GC30879@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: Hou Tao <houtao1@huawei.com>, phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/12/17 18:33, Michal Hocko wrote:
> On Sun 16-12-18 19:51:57, Matthew Wilcox wrote:
> [...]
>> Ah, yes, that makes perfect sense.  Thank you for the explanation.
>>
>> I wonder if the correct fix, however, is not to move the check for
>> GFP_NOFS in out_of_memory() down to below the check whether to kill
>> the current task.  That would solve your problem, and I don't _think_
>> it would cause any new ones.  Michal, you touched this code last, what
>> do you think?
> 
> What do you mean exactly? Whether we kill a current task or something
> else doesn't change much on the fact that NOFS is a reclaim restricted
> context and we might kill too early. If the fs can do GFP_FS then it is
> obviously a better thing to do because FS metadata can be reclaimed as
> well and therefore there is potentially less memory pressure on
> application data.
> 

I interpreted "to move the check for GFP_NOFS in out_of_memory() down to
below the check whether to kill the current task" as

@@ -1077,15 +1077,6 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
-	 * The OOM killer does not compensate for IO-less reclaim.
-	 * pagefault_out_of_memory lost its gfp context so we have to
-	 * make sure exclude 0 mask - all other users should have at least
-	 * ___GFP_DIRECT_RECLAIM to get here.
-	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
-		return true;
-
-	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
 	 */
@@ -1104,6 +1095,19 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	select_bad_process(oc);
+
+	/*
+	 * The OOM killer does not compensate for IO-less reclaim.
+	 * pagefault_out_of_memory lost its gfp context so we have to
+	 * make sure exclude 0 mask - all other users should have at least
+	 * ___GFP_DIRECT_RECLAIM to get here.
+	 */
+	if ((oc->gfp_mask && !(oc->gfp_mask & __GFP_FS)) && oc->chosen &&
+	    oc->chosen != (void *)-1UL && oc->chosen != current) {
+		put_task_struct(oc->chosen);
+		return true;
+	}
+
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
 		dump_header(oc, NULL);

which is prefixed by "the correct fix is not".

Behaving like sysctl_oom_kill_allocating_task == 1 if __GFP_FS is not used
will not be the correct fix. But ...

Hou Tao wrote:
> There is no need to disable __GFP_FS in ->readpage:
> * It's a read-only fs, so there will be no dirty/writeback page and
>   there will be no deadlock against the caller's locked page

is read-only filesystem sufficient for safe to use __GFP_FS?

Isn't "whether it is safe to use __GFP_FS" depends on "whether fs locks
are held or not" rather than "whether fs has dirty/writeback page or not" ?
