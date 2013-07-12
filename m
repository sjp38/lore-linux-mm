Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id ACE406B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:18:05 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id hr11so7468681vcb.34
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 23:18:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51DF9794.4010000@kernel.org>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<51DF9794.4010000@kernel.org>
Date: Thu, 11 Jul 2013 23:18:04 -0700
Message-ID: <CAMbhsRRybw+7wyNMrnnu+DMfDSGyMzrqidiY1tNXiTQBYkAsTw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Jul 11, 2013 at 10:43 PM, Pekka Enberg <penberg@kernel.org> wrote:
> On 07/12/2013 05:34 AM, Colin Cross wrote:
>>
>> Userspace processes often have multiple allocators that each do
>> anonymous mmaps to get memory.  When examining memory usage of
>> individual processes or systems as a whole, it is useful to be
>> able to break down the various heaps that were allocated by
>> each layer and examine their size, RSS, and physical memory
>> usage.
>>
>> This patch adds a user pointer to the shared union in
>> vm_area_struct that points to a null terminated string inside
>> the user process containing a name for the vma.  vmas that
>> point to the same address will be merged, but vmas that
>> point to equivalent strings at different addresses will
>> not be merged.
>>
>> Userspace can set the name for a region of memory by calling
>> prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, start, len, (unsigned long)name);
>> Setting the name to NULL clears it.
>>
>> The names of named anonymous vmas are shown in /proc/pid/maps
>> as [anon:<name>] and in /proc/pid/smaps in a new "Name" field
>> that is only present for named vmas.  If the userspace pointer
>> is no longer valid all or part of the name will be replaced
>> with "<fault>".
>>
>> The idea to store a userspace pointer to reduce the complexity
>> within mm (at the expense of the complexity of reading
>> /proc/pid/mem) came from Dave Hansen.  This results in no
>> runtime overhead in the mm subsystem other than comparing
>> the anon_name pointers when considering vma merging.  The pointer
>> is stored in a union with fieds that are only used on file-backed
>> mappings, so it does not increase memory usage.
>>
>> Signed-off-by: Colin Cross <ccross@android.com>
>
>
> So how does this perform if I do prctl(PR_SET_VMA_ANON_NAME)
> for thousands of relatively small (max 1 KB) JIT generated
> functions? Will we run into MM problems because the VMAs are
> not mergeable?

This operates on vmas, so it can only handle naming page aligned
regions.  It would work fine to identify the regions that contain JIT
code, but not to identify individual functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
