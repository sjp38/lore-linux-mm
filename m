Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 283106B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:12:42 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so65986022pac.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:12:41 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w16si20260752pbs.251.2015.11.12.06.12.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Nov 2015 06:12:40 -0800 (PST)
Subject: Re: memory reclaim problems on fs usage
References: <201511102313.36685.arekm@maven.pl>
 <201511111719.44035.arekm@maven.pl>
 <201511120719.EBF35970.OtSOHOVFJMFQFL@I-love.SAKURA.ne.jp>
 <201511120706.10739.arekm@maven.pl>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <56449E44.7020407@I-love.SAKURA.ne.jp>
Date: Thu, 12 Nov 2015 23:12:20 +0900
MIME-Version: 1.0
In-Reply-To: <201511120706.10739.arekm@maven.pl>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Arkadiusz_Mi=c5=9bkiewicz?= <arekm@maven.pl>
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On 2015/11/12 15:06, Arkadiusz MiA?kiewicz wrote:
> On Wednesday 11 of November 2015, Tetsuo Handa wrote:
>> Arkadiusz Mi?kiewicz wrote:
>>> This patch is against which tree? (tried 4.1, 4.2 and 4.3)
>>
>> Oops. Whitespace-damaged. This patch is for vanilla 4.1.2.
>> Reposting with one condition corrected.
>
> Here is log:
>
> http://ixion.pld-linux.org/~arekm/log-mm-1.txt.gz
>
> Uncompresses is 1.4MB, so not posting here.
>
Thank you for the log. The result is unexpected for me.

What I feel strange is that free: remained below min: level.
While GFP_ATOMIC allocations can access memory reserves, I think that
these free: values are too small. Memory allocated by GFP_ATOMIC should
be released shortly, or any __GFP_WAIT allocations would stall for long.

[ 8633.753528] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:59008kB inactive_anon:75240kB active_file:14712kB inactive_file:3256960kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:20kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697520kB slab_unreclaimable:274524kB kernel_stack:2000kB 
pagetables:2088kB unstable:0kB bounce:0kB free_pcp:1072kB local_pcp:672kB free_cma:128kB writeback_tmp:0kB pages_scanned:176 all_unreclaimable? no
[ 8678.467783] Node 0 Normal free:228kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3244288kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:4kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194712kB kernel_stack:1968kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:796kB local_pcp:64kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9460.400303] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9462.401840] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9464.403368] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9466.404900] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9468.406432] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9470.407964] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9472.409498] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9474.411031] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9476.412561] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9478.414094] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9480.415627] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9482.417161] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9484.418691] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9486.420224] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9488.421755] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9490.423290] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9492.424822] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9494.426353] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9496.427886] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9498.429419] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9500.430955] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3241920kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697376kB slab_unreclaimable:194860kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:584kB local_pcp:584kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9502.432503] Node 0 Normal free:40kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3240344kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697304kB slab_unreclaimable:194896kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9504.434015] Node 0 Normal free:404kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3238768kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697304kB slab_unreclaimable:194928kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9506.435566] Node 0 Normal free:280kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3237192kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697304kB slab_unreclaimable:194960kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:68kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9508.437089] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3235616kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697304kB slab_unreclaimable:194972kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9510.438640] Node 0 Normal free:200kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3234040kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697232kB slab_unreclaimable:194980kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:136kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9512.440155] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3232464kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697232kB slab_unreclaimable:194984kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9514.441700] Node 0 Normal free:616kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3230888kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697232kB slab_unreclaimable:194996kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:148kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9516.443219] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3229312kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697232kB slab_unreclaimable:195040kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9518.444745] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3227736kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697160kB slab_unreclaimable:195076kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:20 all_unreclaimable? no
[ 9520.446278] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3226164kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697160kB slab_unreclaimable:195104kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9522.447819] Node 0 Normal free:412kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3224596kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697156kB slab_unreclaimable:195132kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:68kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9524.449349] Node 0 Normal free:1544kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3223028kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697088kB slab_unreclaimable:195152kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:12kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9526.450875] Node 0 Normal free:404kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3221460kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697080kB slab_unreclaimable:195196kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9528.452403] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3219892kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697080kB slab_unreclaimable:195228kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9530.453942] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3218324kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697080kB slab_unreclaimable:195248kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9532.455470] Node 0 Normal free:348kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3216756kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697012kB slab_unreclaimable:195272kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:88kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9534.457005] Node 0 Normal free:1268kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3215188kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697012kB slab_unreclaimable:195300kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9536.458545] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3213620kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:697008kB slab_unreclaimable:195316kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9538.460069] Node 0 Normal free:0kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3212052kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696952kB slab_unreclaimable:195352kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9540.461626] Node 0 Normal free:128kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3210484kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696952kB slab_unreclaimable:195356kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:16 all_unreclaimable? no
[ 9542.463166] Node 0 Normal free:1696kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3208924kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696952kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.465161] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.465338] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.465498] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.465662] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.465825] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.465984] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[ 9544.466143] Node 0 Normal free:2756kB min:7104kB low:8880kB high:10656kB active_anon:58992kB inactive_anon:75240kB active_file:14732kB inactive_file:3207364kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:5242880kB managed:5109980kB mlocked:0kB dirty:0kB writeback:0kB mapped:7368kB shmem:0kB slab_reclaimable:696948kB slab_unreclaimable:195348kB kernel_stack:1920kB 
pagetables:2084kB unstable:0kB bounce:0kB free_pcp:112kB local_pcp:112kB free_cma:128kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no

There is no OOM victims thus ALLOC_NO_WATERMARKS is not by TIF_MEMDIE.
There are many stalls which lasted for finite period. Sometimes the system
slowed down, but it was not a livelock.

[ 1065.668820] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1075.676226] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1085.683607] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1095.690955] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1105.698273] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1115.705598] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1125.712926] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1145.727590] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1155.734973] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1165.742333] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1175.749707] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1185.757076] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1195.764440] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1205.771807] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1215.779177] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1235.793909] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1245.801276] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1255.808647] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1275.823377] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1285.830754] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1295.838130] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 1305.845492] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1315.852860] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1325.860228] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1335.867595] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1345.874966] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 1365.889706] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1375.897073] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1385.904443] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1405.919177] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 1415.926283] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1425.933051] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1435.939906] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1445.947270] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1455.954635] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1465.961996] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1475.969365] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1485.976728] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1495.984092] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1505.991462] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1515.998823] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1526.006189] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1536.013556] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1556.028246] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1576.042951] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 1586.050273] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1596.057617] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1606.064958] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1616.072324] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1626.079639] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1636.086982] MemAlloc-Info: 7 stalling task, 0 dying task, 0 victim task.
[ 1656.101667] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1666.109005] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1706.138381] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1716.145730] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 1726.153060] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1736.160403] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1746.167741] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1756.175086] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1766.182427] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1776.189773] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1786.197115] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1796.204463] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1806.211968] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1816.219514] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1826.227075] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 1856.249436] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1866.256788] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1876.264140] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1886.271494] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 1906.286192] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1916.293546] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1936.308288] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1946.315699] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 1966.330503] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 1986.345304] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2006.360045] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2016.367414] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2026.374783] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2036.382152] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 2046.389518] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2076.411626] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2086.419002] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2096.426372] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 2106.433740] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 2116.441108] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 2126.448478] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2156.486445] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2176.501708] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2196.516972] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 2206.524607] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2226.539866] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2236.547503] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2246.555129] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2276.578029] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2286.585663] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2306.600929] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2316.608562] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2326.616191] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2346.631457] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2356.639093] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 2366.646733] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2376.654360] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2426.692537] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 2436.700160] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2486.738327] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 2496.745962] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 2516.761238] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2526.768860] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2536.776489] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2546.784126] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 2566.799391] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2576.807024] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2586.814659] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2626.845195] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2636.852824] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2706.907138] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2726.922671] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2736.930441] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 2746.938204] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 2826.999851] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 3067.183816] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3087.199151] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3477.497792] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3567.566694] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3577.574349] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 3587.582008] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 3597.589662] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 3607.597314] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 3617.604974] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 3637.620285] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3647.627939] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3717.681530] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 3797.742794] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4238.079941] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4338.156578] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 4468.256201] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4558.325170] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4618.371150] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4788.501423] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4828.532079] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4858.555065] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 4898.585719] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5058.711672] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5469.025717] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5559.094621] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5649.163542] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5669.178855] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5679.186511] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5709.209479] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5759.247766] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5939.385591] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 5989.423875] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6009.439191] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6019.446849] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6029.454508] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6079.492787] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6089.500450] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6099.508106] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6109.515761] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6119.523421] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6129.531076] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6199.584674] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6209.592332] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6229.607647] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6239.615305] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6249.622965] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6269.638288] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6559.860274] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[ 6739.998076] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 8401.269303] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 8411.276966] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8421.284631] MemAlloc-Info: 7 stalling task, 0 dying task, 0 victim task.
[ 8431.292299] MemAlloc-Info: 8 stalling task, 0 dying task, 0 victim task.
[ 8441.299951] MemAlloc-Info: 9 stalling task, 0 dying task, 0 victim task.
[ 8451.307616] MemAlloc-Info: 7 stalling task, 0 dying task, 0 victim task.
[ 8461.315273] MemAlloc-Info: 7 stalling task, 0 dying task, 0 victim task.
[ 8481.330599] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 8491.338257] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 8501.345922] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 8511.353584] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8521.361249] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8531.368911] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8541.376566] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8551.384226] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8561.391891] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 8571.399551] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 8581.407215] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 8591.414878] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 8601.422538] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 8611.430199] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
[ 8621.437860] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8631.445524] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 8641.453189] MemAlloc-Info: 8 stalling task, 0 dying task, 0 victim task.
[ 8651.460845] MemAlloc-Info: 8 stalling task, 0 dying task, 0 victim task.
[ 8661.468509] MemAlloc-Info: 8 stalling task, 0 dying task, 0 victim task.
[ 8671.476177] MemAlloc-Info: 8 stalling task, 0 dying task, 0 victim task.
[ 9462.081427] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
[ 9472.089089] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
[ 9482.096751] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
[ 9492.104413] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
[ 9502.112092] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
[ 9512.119764] MemAlloc-Info: 15 stalling task, 0 dying task, 0 victim task.
[ 9522.127417] MemAlloc-Info: 15 stalling task, 0 dying task, 0 victim task.
[ 9532.135091] MemAlloc-Info: 15 stalling task, 0 dying task, 0 victim task.
[ 9542.142743] MemAlloc-Info: 15 stalling task, 0 dying task, 0 victim task.
[ 9552.150406] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
[ 9562.158067] MemAlloc-Info: 15 stalling task, 0 dying task, 0 victim task.
[ 9572.165732] MemAlloc-Info: 15 stalling task, 0 dying task, 0 victim task.
[ 9612.196377] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 9622.204042] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 9632.211698] MemAlloc-Info: 6 stalling task, 0 dying task, 0 victim task.
[ 9642.219358] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 9652.227029] MemAlloc-Info: 5 stalling task, 0 dying task, 0 victim task.
[ 9662.234685] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.

vmstat_update() and submit_flushes() remained pending for about 110 seconds.
If xlog_cil_push_work() were spinning inside GFP_NOFS allocation, it should be
reported as MemAlloc: traces, but no such lines are recorded. I don't know why
xlog_cil_push_work() did not call schedule() for so long. Anyway, applying
http://lkml.kernel.org/r/20151111160336.GD1432@dhcp22.suse.cz should solve
vmstat_update() part.

[ 8491.338279] Showing busy workqueues and worker pools:
[ 8491.338281] workqueue events: flags=0x0
[ 8491.338283]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 8491.338287]     pending: vmstat_update, e1000_watchdog_task [e1000e]
[ 8491.338310] workqueue md: flags=0x8
[ 8491.338312]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 8491.338315]     pending: submit_flushes [md_mod]
[ 8491.338333] workqueue xfs-cil/md3: flags=0xc
[ 8491.338334]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 8491.338336]     in-flight: 8895:xlog_cil_push_work [xfs] BAR(576)
[ 8491.338368] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=3 manager: 12328 idle: 9632 8646
[ 8491.338372] pool 1: cpus=0 node=0 flags=0x0 nice=-20 workers=3 manager: 12327 idle: 4592 11916
[ 8491.338377] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=2 manager: 11509
(...snipped...)
[ 8601.422538] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
[ 8601.422542] MemAlloc: kthreadd(2) gfp=0x2000d0 order=2 delay=61314
[ 8601.422544] MemAlloc: ssh(9797) gfp=0xd0 order=0 delay=60227
[ 8601.422546] MemAlloc: cp(10054) gfp=0x2052d0 order=3 delay=57397
[ 8601.422547] MemAlloc: irqbalance(703) gfp=0x280da order=0 delay=54234
[ 8601.422557] Showing busy workqueues and worker pools:
[ 8601.422559] workqueue events: flags=0x0
[ 8601.422561]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=5/256
[ 8601.422566]     pending: vmstat_update, e1000_watchdog_task [e1000e], vmpressure_work_fn, kernfs_notify_workfn, key_garbage_collector
[ 8601.422597] workqueue md: flags=0x8
[ 8601.422598]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 8601.422601]     pending: submit_flushes [md_mod]
[ 8601.422619] workqueue xfs-cil/md3: flags=0xc
[ 8601.422621]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 8601.422623]     in-flight: 8895:xlog_cil_push_work [xfs] BAR(4592) BAR(576)
[ 8601.422653] workqueue xfs-log/md3: flags=0x1c
[ 8601.422655]   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
[ 8601.422658]     in-flight: 4592:xfs_log_worker [xfs]
[ 8601.422680] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=3 manager: 12328 idle: 9632 8646
[ 8601.422684] pool 1: cpus=0 node=0 flags=0x0 nice=-20 workers=3 manager: 12327 idle: 11916
[ 8601.422688] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=2 manager: 11509

Well, what steps should we try next for isolating the problem?

Swap is not used at all. Turning off swap might help.

[ 8633.753574] Free swap  = 117220800kB
[ 8633.753576] Total swap = 117220820kB

Turning off perf might also help.

[ 5001.394085] perf interrupt took too long (2505 > 2495), lowering kernel.perf_event_max_sample_rate to 50100

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
