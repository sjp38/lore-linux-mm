Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 65B5F6B009B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 05:00:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8BB9F3EE0C0
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:00:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7176745DEC3
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:00:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5518D45DEBA
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:00:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4777A1DB8045
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:00:21 +0900 (JST)
Received: from g01jpexchkw30.g01.fujitsu.local (g01jpexchkw30.g01.fujitsu.local [10.0.193.113])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBDC51DB8047
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:00:20 +0900 (JST)
Message-ID: <50B48F0B.60704@jp.fujitsu.com>
Date: Tue, 27 Nov 2012 18:59:39 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <CAA_GA1d7CxHvmZELvD_DO6u5tu1WBqfmLiuEzeFo=xMzuW50Tg@mail.gmail.com> <50B479FA.6010307@cn.fujitsu.com> <50B47EB7.20000@zytor.com>
In-Reply-To: <50B47EB7.20000@zytor.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, rob@landley.net, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi HPA and Tang,

2012/11/27 17:49, H. Peter Anvin wrote:
> On 11/27/2012 12:29 AM, Tang Chen wrote:
>> Another approach is like the following:
>> movable_node = 1,3-5,8
>> This could set all the memory on the nodes to be movable. And the rest
>> of memory works as usual. But movablecore_map is more flexible.
>
> ... but *much* harder for users, so movable_node is better in most cases.

It seems that movable_node is easier to use than movablecore_map.
But I do not think movable_node is better because the node number is set
by OS and changed easily.


For exmaple:
If system has 4 nodes and we set moveble_node=2, we can hot remove node2.

    node0   node1   node2   node3
   +-----+ +-----+ +-----+ +-----+
   |     | |     | |/////| |     |
   |     | |     | |/////| |     |
   |     | |     | |/////| |     |
   |     | |     | |/////| |     |
   +-----+ +-----+ +-----+ +-----+
                   movable
                    node

But if we hot remove node2 and reboot the system, node3 is changed to node2
and set to movable node.

    node0   node1           node2
   +-----+ +-----+         +-----+
   |     | |     |         |/////|
   |     | |     |         |/////|
   |     | |     |         |/////|
   |     | |     |         |/////|
   +-----+ +-----+         +-----+
                           movable
                            node

Originally, node3 is not movable node. Changing the node attribution to
movable node is not intended. So if user uses movable_node,
user must confirm whether boot option is correctly set at hotplug.

But memory range is set by firmware and not changed. So if we set node2
as movable node by movablecore_map, the issue does not occur.

Thanks,
Yasuaki Ishimatsu

>
> 	-hpa
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
