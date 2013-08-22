Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E78A96B0070
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:25:35 -0400 (EDT)
Message-ID: <5215D90B.2050008@redhat.com>
Date: Thu, 22 Aug 2013 11:25:31 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add overcommit_kbytes sysctl variable
References: <1376925478-15506-1-git-send-email-jmarchan@redhat.com> <1376925478-15506-2-git-send-email-jmarchan@redhat.com> <52124DE7.8070502@intel.com> <5214DB1B.6070803@redhat.com> <5214E96B.3090009@intel.com>
In-Reply-To: <5214E96B.3090009@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/21/2013 06:23 PM, Dave Hansen wrote:
> On 08/21/2013 08:22 AM, Jerome Marchand wrote:
>>>> Instead of introducing yet another tunable, why don't we just make the
>>>> ratio that comes in from the user more fine-grained?
>>>>
>>>> 	sysctl overcommit_ratio=0.2
>>>>
>>>> We change the internal 'sysctl_overcommit_ratio' to store tenths or
>>>> hundreths of a percent (or whatever), then parse the input as two
>>>> integers.  I don't think we need fully correct floating point parsing
>>>> and rounding here, so it shouldn't be too much of a chore.  It'd
>>>> probably end up being less code than you have as it stands.
>>>>
>> Now that I think about it, that could break user space. Sure write access
>> wouldn't be a problem (one can still write a plain integer), but a script
>> that reads a fractional value when it expects an integer might not be able
>> to cope with it.
> 
> You're right.  Something doing FOO=$(cat overcommit_ratio) and then
> trying do do arithmetic would just fail loudly.  But, it would probably
> fail silently if we create another tunable that all of a sudden returns
> 0 (when the kernel is not _behaving_ like it is set to 0).
> 
> I'm not sure there's a good way out of this without breakage (or at
> least confusing) of _some_ old scripts/programs.  Either way has ups and
> downs.
> 
> The existing dirty_ratio/bytes stuff just annoys me because I end up
> having to check two places whenever I go looking for it.
> 

Right. Then we could just use some overcommit_fine_ratio internally and
overcommit_ratio would show and set a rounded value. I doubt that a script
that reads 80% would notice the difference if it is actually 79.5%.

We could also use overcommit_kbytes internally, but then overcommit_ratio
would fluctuate if RAM ram is added/removed (e.g. memory hotplug or baloon
driver). That might be a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
