Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD11A83092
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 16:01:37 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so47177474pab.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 13:01:37 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0a-000ceb01.pphosted.com. [67.231.144.126])
        by mx.google.com with ESMTPS id t12si776800pfj.221.2016.08.18.13.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 13:01:36 -0700 (PDT)
Subject: Re: OOM killer changes
References: <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160815150123.GG3360@dhcp22.suse.cz>
 <1b8ee89d-a851-06f0-6bcc-62fef9e7e7cc@Quantum.com>
 <20160816073246.GC5001@dhcp22.suse.cz> <20160816074316.GD5001@dhcp22.suse.cz>
 <6a22f206-e0e7-67c9-c067-73a55b6fbb41@Quantum.com>
 <a61f01eb-7077-07dd-665a-5125a1f8ef37@suse.cz>
 <0325d79b-186b-7d61-2759-686f8afff0e9@Quantum.com>
 <20160817093323.GB20703@dhcp22.suse.cz>
 <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
 <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
Date: Thu, 18 Aug 2016 13:01:32 -0700
MIME-Version: 1.0
In-Reply-To: <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 17.08.2016 23:57, Vlastimil Babka wrote:
>>>> Hmm. I added linux-next git, fetched it etc but apparently I didn't check
>>>> out the right branch. Do you want next-20160817?
>>> Yes this one should be OK. It contains Vlastimil's patches.
>>>
>>> Thanks!
>> This has been working so far. I built a kernel successfully, with dd
>> writing to two drives. There were a number of messages in the trace pipe
>> but compaction/migration always succeeded it seems.
>> I'll run the big torture test overnight.
> Good news, thanks. Did you also apply Joonsoo's suggested removal of
> suitable_migration_target() check, or is this just the linux-next
> version with added trace_printk()/pr_info()?
>
> Vlastimil
Yes, that change was in my test with linux-next-20160817. Here's the diff:

diff --git a/mm/compaction.c b/mm/compaction.c
index f94ae67..60a9ca2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1083,8 +1083,10 @@ static void isolate_freepages(struct 
compact_control *cc)
                         continue;

                 /* Check the block is suitable for migration */
+/*
                 if (!suitable_migration_target(page))
                         continue;
+*/

                 /* If isolation recently failed, do not retry */
                 if (!isolation_suitable(cc, page))
diff --git a/mm/migrate.c b/mm/migrate.c
index f7ee04a..b1176a4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -827,8 +827,10 @@ static int fallback_migrate_page(struct 
address_space *mapping,
          * We must have no buffers or drop them.
          */
         if (page_has_private(page) &&
-           !try_to_release_page(page, GFP_KERNEL))
+           !try_to_release_page(page, GFP_KERNEL)) {
+               trace_printk("try_to_release_page failed for 
a_ops:%pS\n", page->mapping->a_ops);
                 return -EAGAIN;
+       }

         return migrate_page(mapping, newpage, page, mode);
  }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5637733..b443652 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3202,8 +3202,12 @@ should_compact_retry(struct alloc_context *ac, 
int order, int alloc_flags,
          * But do not retry if the given zonelist is not suitable for
          * compaction.
          */
-       if (compaction_withdrawn(compact_result))
-               return compaction_zonelist_suitable(ac, order, alloc_flags);
+       if (compaction_withdrawn(compact_result)) {
+               int ret = compaction_zonelist_suitable(ac, order, 
alloc_flags);
+               if (!ret)
+                       pr_info("XXX: no zone suitable for compaction\n");
+               return ret;
+       }

         /*
          * !costly requests are much more important than __GFP_REPEAT
@@ -3227,6 +3231,7 @@ check_priority:
                 (*compact_priority)--;
                 return true;
         }
+       pr_info("XXX: compaction retries fail after %d\n", 
compaction_retries);
         return false;
  }
  #else

It ran the whole night with continuous torture tests and writing to two 
drives. No OOM.
Logs are at 
https://filebin.net/l2kp3iit8dj0fq6q/OOM_4.8.0-next-20160817.tar.bz2.

Thanks for fixing this!
Ralf-Peter

----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
