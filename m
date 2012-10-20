Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 3A3166B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 23:39:53 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so1469429vbk.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 20:39:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
Date: Sat, 20 Oct 2012 11:39:52 +0800
Message-ID: <CAJd=RBAABS5Vt7pquAxfbhPZzAb1n-qM_VRTwXUc0uQRU1Ky0A@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Sat, Oct 20, 2012 at 12:48 AM, Andi Kleen <andi@firstfloor.org> wrote:
> From: Andi Kleen <ak@linux.intel.com>
>
> There was some desire in large applications using MAP_HUGETLB/SHM_HUGETLB
> to use 1GB huge pages on some mappings, and stay with 2MB on others. This
> is useful together with NUMA policy: use 2MB interleaving on some mappings,
> but 1GB on local mappings.
>
> This patch extends the IPC/SHM syscall interfaces slightly to allow specifying
> the page size.
>
> It borrows some upper bits in the existing flag arguments and allows encoding
> the log of the desired page size in addition to the *_HUGETLB flag.
> When 0 is specified the default size is used, this makes the change fully
> compatible.
>
> Extending the internal hugetlb code to handle this is straight forward. Instead
> of a single mount it just keeps an array of them and selects the right
> mount based on the specified page size. When no page size is specified
> it uses the mount of the default page size.
>
> The change is not visible in /proc/mounts because internal mounts
> don't appear there. It also has very little overhead: the additional
> mounts just consume a super block, but not more memory when not used.
>
> I also exported the new flags to the user headers
> (they were previously under __KERNEL__). Right now only symbols
> for x86 and some other architecture for 1GB and 2MB are defined.
> The interface should already work for all other architectures
> though.  Only architectures that define multiple hugetlb sizes
> actually need it (that is currently x86, tile, powerpc). However
> tile and powerpc have user configurable hugetlb sizes, so it's
> not easy to add defines. A program on those architectures would
> need to query sysfs and use the appropiate log2.
>
> v2: Port to new tree. Fix unmount.
> v3: Ported to latest tree.
> v4: Ported to latest tree. Minor changes for review feedback. Updated
> description.
> v5: Remove unnecessary prototypes to fix merge error (Hillf Danton)
> v6: Rebased. Fix some unlikely error paths (Hillf Danton)
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Hillf Danton <dhillf@gmail.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---

Thanks:)

Acked-by: Hillf Danton <dhillf@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
