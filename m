Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFA96B000C
	for <linux-mm@kvack.org>; Thu,  3 May 2018 18:35:39 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t24-v6so14449846qtn.7
        for <linux-mm@kvack.org>; Thu, 03 May 2018 15:35:39 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q6-v6si2279051qtl.131.2018.05.03.15.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 15:35:38 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <cac754ee-efb9-0259-a50b-4efa11783058@oracle.com>
 <20180503085741.GD4535@dhcp22.suse.cz>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <40be68bb-8322-2bef-f454-22e1ab9029da@oracle.com>
Date: Thu, 3 May 2018 15:37:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180503085741.GD4535@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>, Dave Hansen <dave.hansen@intel.com>



On 05/03/2018 01:57 AM, Michal Hocko wrote:
> On Wed 02-05-18 16:43:58, prakash.sangappa wrote:
>>
>> On 05/02/2018 02:33 PM, Andrew Morton wrote:
>>> On Tue,  1 May 2018 22:58:06 -0700 Prakash Sangappa <prakash.sangappa@oracle.com> wrote:
>>>
>>>> For analysis purpose it is useful to have numa node information
>>>> corresponding mapped address ranges of the process. Currently
>>>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>>>> allocated per VMA of the process. This is not useful if an user needs to
>>>> determine which numa node the mapped pages are allocated from for a
>>>> particular address range. It would have helped if the numa node information
>>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>>> exact numa node from where the pages have been allocated.
>>>>
>>>> The format of /proc/<pid>/numa_maps file content is dependent on
>>>> /proc/<pid>/maps file content as mentioned in the manpage. i.e one line
>>>> entry for every VMA corresponding to entries in /proc/<pids>/maps file.
>>>> Therefore changing the output of /proc/<pid>/numa_maps may not be possible.
>>>>
>>>> Hence, this patch proposes adding file /proc/<pid>/numa_vamaps which will
>>>> provide proper break down of VA ranges by numa node id from where the mapped
>>>> pages are allocated. For Address ranges not having any pages mapped, a '-'
>>>> is printed instead of numa node id. In addition, this file will include most
>>>> of the other information currently presented in /proc/<pid>/numa_maps. The
>>>> additional information included is for convenience. If this is not
>>>> preferred, the patch could be modified to just provide VA range to numa node
>>>> information as the rest of the information is already available thru
>>>> /proc/<pid>/numa_maps file.
>>>>
>>>> Since the VA range to numa node information does not include page's PFN,
>>>> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
>>>>
>>>> Here is the snippet from the new file content showing the format.
>>>>
>>>> 00400000-00401000 N0=1 kernelpagesize_kB=4 mapped=1 file=/tmp/hmap2
>>>> 00600000-00601000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 file=/tmp/hmap2
>>>> 00601000-00602000 N0=1 kernelpagesize_kB=4 anon=1 dirty=1 file=/tmp/hmap2
>>>> 7f0215600000-7f0215800000 N0=1 kernelpagesize_kB=2048 dirty=1 file=/mnt/f1
>>>> 7f0215800000-7f0215c00000 -  file=/mnt/f1
>>>> 7f0215c00000-7f0215e00000 N0=1 kernelpagesize_kB=2048 dirty=1 file=/mnt/f1
>>>> 7f0215e00000-7f0216200000 -  file=/mnt/f1
>>>> ..
>>>> 7f0217ecb000-7f0217f20000 N0=85 kernelpagesize_kB=4 mapped=85 mapmax=51
>>>>      file=/usr/lib64/libc-2.17.so
>>>> 7f0217f20000-7f0217f30000 -  file=/usr/lib64/libc-2.17.so
>>>> 7f0217f30000-7f0217f90000 N0=96 kernelpagesize_kB=4 mapped=96 mapmax=51
>>>>      file=/usr/lib64/libc-2.17.so
>>>> 7f0217f90000-7f0217fb0000 -  file=/usr/lib64/libc-2.17.so
>>>> ..
>>>>
>>>> The 'pmap' command can be enhanced to include an option to show numa node
>>>> information which it can read from this new proc file. This will be a
>>>> follow on proposal.
>>> I'd like to hear rather more about the use-cases for this new
>>> interface.  Why do people need it, what is the end-user benefit, etc?
>> This is mainly for debugging / performance analysis. Oracle Database
>> team is looking to use this information.
> But we do have an interface to query (e.g. move_pages) that your
> application can use. I am really worried that the broken out per node
> data can be really large (just take a large vma with interleaved policy
> as an example). So is this really worth adding as a general purpose proc
> interface?

I guess move_pages could be useful. There needs to be a tool or
command which can read the numa node information using move_pages
to be used to observe another process.

 From an observability point of view, one of the use of the proposed
new file 'numa_vamaps' was to modify  'pmap' command to display numa
node information broken down by address ranges.  Would having pmap
show numa node information be useful?
