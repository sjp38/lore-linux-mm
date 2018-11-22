Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 780296B2DF6
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 18:42:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so4936319edh.8
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 15:42:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9-v6sor27255036edr.10.2018.11.22.15.42.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 15:42:01 -0800 (PST)
Date: Thu, 22 Nov 2018 23:41:59 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked node
 in get_any_partial()
Message-ID: <20181122234159.5hrhxioe6b777ttb@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181120033119.30013-1-richard.weiyang@gmail.com>
 <20181121190555.c010ac50e7eaa141549a63e5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121190555.c010ac50e7eaa141549a63e5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, mhocko@kernel.org, linux-mm@kvack.org

On Wed, Nov 21, 2018 at 07:05:55PM -0800, Andrew Morton wrote:
>On Tue, 20 Nov 2018 11:31:19 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> 1. Background
>> 
>>   Current slub has three layers:
>> 
>>     * cpu_slab
>>     * percpu_partial
>>     * per node partial list
>> 
>>   Slub allocator tries to get an object from top to bottom. When it can't
>>   get an object from the upper two layers, it will search the per node
>>   partial list. The is done in get_partial().
>> 
>>   The abstraction of get_partial() may looks like this:
>> 
>>       get_partial()
>>           get_partial_node()
>>           get_any_partial()
>>               for_each_zone_zonelist()
>> 
>>   The idea behind this is: it first try a local node, then try other nodes
>>   if caller doesn't specify a node.
>> 
>> 2. Room for Improvement
>> 
>>   When we look one step deeper in get_any_partial(), it tries to get a
>>   proper node by for_each_zone_zonelist(), which iterates on the
>>   node_zonelists.
>> 
>>   This behavior would introduce some redundant check on the same node.
>>   Because:
>> 
>>     * the local node is already checked in get_partial_node()
>>     * one node may have several zones on node_zonelists
>> 
>> 3. Solution Proposed in Patch
>> 
>>   We could reduce these redundant check by record the last unsuccessful
>>   node and then skip it.
>> 
>> 4. Tests & Result
>> 
>>   After some tests, the result shows this may improve the system a little,
>>   especially on a machine with only one node.
>> 
>> 4.1 Test Description
>> 
>>   There are two cases for two system configurations.
>> 
>>   Test Cases:
>> 
>>     1. counter comparison
>>     2. kernel build test
>> 
>>   System Configuration:
>> 
>>     1. One node machine with 4G
>>     2. Four node machine with 8G
>> 
>> 4.2 Result for Test 1
>> 
>>   Test 1: counter comparison
>> 
>>   This is a test with hacked kernel to record times function
>>   get_any_partial() is invoked and times the inner loop iterates. By
>>   comparing the ratio of two counters, we get to know how many inner
>>   loops we skipped.
>> 
>>   Here is a snip of the test patch.
>> 
>>   ---
>>   static void *get_any_partial() {
>> 
>> 	get_partial_count++;
>> 
>>         do {
>> 		for_each_zone_zonelist() {
>> 			get_partial_try_count++;
>> 		}
>> 	} while();
>> 
>> 	return NULL;
>>   }
>>   ---
>> 
>>   The result of (get_partial_count / get_partial_try_count):
>> 
>>    +----------+----------------+------------+-------------+
>>    |          |       Base     |    Patched |  Improvement|
>>    +----------+----------------+------------+-------------+
>>    |One Node  |       1:3      |    1:0     |      - 100% |
>>    +----------+----------------+------------+-------------+
>>    |Four Nodes|       1:5.8    |    1:2.5   |      -  56% |
>>    +----------+----------------+------------+-------------+
>> 
>> 4.3 Result for Test 2
>> 
>>   Test 2: kernel build
>> 
>>    Command used:
>> 
>>    > time make -j8 bzImage
>> 
>>    Each version/system configuration combination has four round kernel
>>    build tests. Take the average result of real to compare.
>> 
>>    +----------+----------------+------------+-------------+
>>    |          |       Base     |   Patched  |  Improvement|
>>    +----------+----------------+------------+-------------+
>>    |One Node  |      4m41s     |   4m32s    |     - 4.47% |
>>    +----------+----------------+------------+-------------+
>>    |Four Nodes|      4m45s     |   4m39s    |     - 2.92% |
>>    +----------+----------------+------------+-------------+
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> 
>
>Looks good to me, but I'll await input from the slab maintainers before
>proceeding any further.
>
>I didn't like the variable name much, and the comment could be
>improved.  Please review:
>

Can I add this?

Reviewed-by: Wei Yang <richard.weiyang@gmail.com>


-- 
Wei Yang
Help you, Help me
