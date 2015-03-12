Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E3F48829AD
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 15:45:43 -0400 (EDT)
Received: by padfa1 with SMTP id fa1so23008802pad.9
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 12:45:43 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id bd12si7221137pdb.255.2015.03.12.12.45.42
        for <linux-mm@kvack.org>;
        Thu, 12 Mar 2015 12:45:42 -0700 (PDT)
Message-ID: <5501ECE5.7080107@akamai.com>
Date: Thu, 12 Mar 2015 15:45:41 -0400
From: Eric B Munson <emunson@akamai.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4] Allow compaction of unevictable pages
References: <1426173776-23471-1-git-send-email-emunson@akamai.com> <20150312193038.GB20841@dhcp22.suse.cz>
In-Reply-To: <20150312193038.GB20841@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 03/12/2015 03:30 PM, Michal Hocko wrote:
> On Thu 12-03-15 11:22:56, Eric B Munson wrote:
>> Currently, pages which are marked as unevictable are protected
>> from compaction, but not from other types of migration.  The
>> mlock desctription does not promise that all page faults will be
>> avoided, only major ones so this protection is not necessary.
>> This extra protection can cause problems for applications that
>> are using mlock to avoid swapping pages out, but require order >
>> 0 allocations to continue to succeed in a fragmented environment.
>> This patch adds a sysctl entry that will be used to allow root to
>> enable compaction of unevictable pages.
> 
> It would be appropriate to add a justification for the sysctl,
> because it is not obvious from the above description. mlock
> preventing from the swapout is not sufficient to justify it. It is
> the real time extension mentioned by Peter in the previous version
> which makes it worth a new user visible knob.
> 
> I would also argue that the knob should be enabled by default
> because the real time extension requires an additional changes
> anyway (rt-kernel at least) while general usage doesn't need such a
> strong requirement.

Thanks for the review, I will incorporate your suggestions into a V5.
 I agree that many users will want to set this to 1, but keeping the
default to 0 maintains the behavior of the kernel today.  I'd like to
have the real time folks say that they are okay with a default of 1
before I make that change.

> 
> You also should provide a knob description to 
> Documentation/sysctl/vm.txt

Will do.

> 
>> To illustrate this problem I wrote a quick test program that
>> mmaps a large number of 1MB files filled with random data.  These
>> maps are created locked and read only.  Then every other mmap is
>> unmapped and I attempt to allocate huge pages to the static huge
>> page pool.  When the compact_unevictable sysctl is 0, I cannot
>> allocate hugepages after fragmenting memory.  When the value is
>> set to 1, allocations succeed.
>> 
>> Signed-off-by: Eric B Munson <emunson@akamai.com> Cc: Vlastimil
>> Babka <vbabka@suse.cz> Cc: Thomas Gleixner <tglx@linutronix.de> 
>> Cc: Christoph Lameter <cl@linux.com> Cc: Peter Zijlstra
>> <peterz@infradead.org> Cc: Mel Gorman <mgorman@suse.de> Cc: David
>> Rientjes <rientjes@google.com> Cc: Rik van Riel
>> <riel@redhat.com> Cc: linux-mm@kvack.org Cc:
>> linux-kernel@vger.kernel.org
> 
> After the above things are fixed Acked-by: Michal Hocko
> <mhocko@suse.cz>
> 
> One minor suggestion below
> 
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c index
>> 88ea2d6..cc1a678 100644 --- a/kernel/sysctl.c +++
>> b/kernel/sysctl.c @@ -1313,6 +1313,13 @@ static struct ctl_table
>> vm_table[] = { .extra1		= &min_extfrag_threshold, .extra2		=
>> &max_extfrag_threshold, }, +	{ +		.procname	=
>> "compact_unevictable", +		.data		= &sysctl_compact_unevictable, +
>> .maxlen		= sizeof(int), +		.mode		= 0644, +		.proc_handler	=
>> proc_dointvec,
> 
> You can use .extra1 = &zero and .extra2 = &one to reduce the value 
> space.
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJVAezjAAoJELbVsDOpoOa9MHwP/j4nvm3dFm00qjOX4RKxsalz
cjhQxuozKnRU9H+OPS3dXXoqDGdpLaLu6CsUsu8FGiJj3zLgUNxea+quJSnSmYVz
8fO5VqhgA3alu7R7zSF3MtOjLzyOoP5/+jDNiNUDLL8sUzg/3hKXLUgBO9R1VU4Q
yD0Yuhw5veNLOvF57xhMCk/quCydIvZV9kAJyTr+fgoY4b8wLyp+QAcqi2lGMCBj
4W9lXtO1abG+gu/m5zAhXLX7MS+ZRQtA070G+kmkY7Z95DtKePGitNjLN7+X9EI6
F1073D+GtiEOJhC+xNOc6Xzwpfl4vRghg4jj6aTkSSrb+sY5/byuKg06p8rMRfef
pJrqjprbBNqiAP95z7X9H6FWty31kx6ZVXtM8CA9/XDqabJGgGs0qmDwPVf264+M
8ySZy5wPRE85yNUKElpvDnx7+t1gka8vDy3bVO+zPsJV3ZqSwhgAiYTTL6u2f/Qe
QwMXWgu4PaAeq0Wltrd/OtA6Fu9H9A91rkk8t69ctPkTjZYCgN0UDGzaa0WpH9SB
H2mz2B3+AE2sdpuoBoVQ62SU4/7PiBIT/ILRuzgQnnNELZFStjstRZPrnVSAYRKI
E5ArRQHfMwbortIiz9KH8SoibTyS0QZiXuKua6LXPwGTnvYqsSN8Jz1XoytV3I5G
MRhLUI7k4dgaVHPTVUYb
=qBj6
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
