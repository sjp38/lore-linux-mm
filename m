Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CD9D56B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:39:18 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so7357831lbh.35
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 22:39:17 -0700 (PDT)
Message-ID: <51DF9682.9040301@kernel.org>
Date: Fri, 12 Jul 2013 08:39:14 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
References: <1373596462-27115-1-git-send-email-ccross@android.com> <1373596462-27115-2-git-send-email-ccross@android.com>
In-Reply-To: <1373596462-27115-2-git-send-email-ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On 07/12/2013 05:34 AM, Colin Cross wrote:
> Userspace processes often have multiple allocators that each do
> anonymous mmaps to get memory.  When examining memory usage of
> individual processes or systems as a whole, it is useful to be
> able to break down the various heaps that were allocated by
> each layer and examine their size, RSS, and physical memory
> usage.
>
> This patch adds a user pointer to the shared union in
> vm_area_struct that points to a null terminated string inside
> the user process containing a name for the vma.  vmas that
> point to the same address will be merged, but vmas that
> point to equivalent strings at different addresses will
> not be merged.
>
> Userspace can set the name for a region of memory by calling
> prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, start, len, (unsigned long)name);
> Setting the name to NULL clears it.
>
> The names of named anonymous vmas are shown in /proc/pid/maps
> as [anon:<name>] and in /proc/pid/smaps in a new "Name" field
> that is only present for named vmas.  If the userspace pointer
> is no longer valid all or part of the name will be replaced
> with "<fault>".
>
> The idea to store a userspace pointer to reduce the complexity
> within mm (at the expense of the complexity of reading
> /proc/pid/mem) came from Dave Hansen.  This results in no
> runtime overhead in the mm subsystem other than comparing
> the anon_name pointers when considering vma merging.  The pointer
> is stored in a union with fieds that are only used on file-backed
> mappings, so it does not increase memory usage.
>
> Signed-off-by: Colin Cross <ccross@android.com>

Ingo, PeterZ, is this something worthwhile for replacing our
current JIT symbol hack with perf?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
