Message-ID: <48080FE7.1070400@windriver.com>
Date: Thu, 17 Apr 2008 22:05:11 -0500
From: Jason Wessel <jason.wessel@windriver.com>
MIME-Version: 1.0
Subject: Re: 2.6.25-mm1: not looking good
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>	<20080417164034.e406ef53.akpm@linux-foundation.org> <20080417171413.6f8458e4.akpm@linux-foundation.org>
In-Reply-To: <20080417171413.6f8458e4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@elte.hu, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 17 Apr 2008 16:40:34 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Thu, 17 Apr 2008 16:03:31 -0700
>> Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> I have maybe two hours in which to weed out whatever very-recently-added
>>> dud patches are causing this.  Any suggestions are welcome.
>>>
>> With git-selinux at top-of tree it's repeatably hanging in the CPA
>> self-tests (git-x86 stuff).  Last two lines are:
>>
>> CPA self-test:
>>  4k 8704 large 4847 gb 0 x 0[0-0] miss 0
>>
>> (clear as mud ;))
>>
>> I will find the config knob to disable that test.  Of course, it could be
>> telling me that CPA is buggy.
>
> Disabling CPA_DEBUG didn't help.  It's still hanging.  The final initcall
> is init_kgdbts() and disabling KGDB prevents the hang.

In this case you do not have to disable kgdb, but just disable the
kgdb test suite.  Certainly I would be interested to know where it is
failing as it would indicate that there is a regression that is caused
by a change that occurred somewhere else in the kernel or a latent
defect in kgdb was triggered.  The kgdb test suite exercises a number
of kernel fault systems as well as arch specific single stepping when
it runs and when it fails it is likely worth it to track down which
test failed and why.

If you are looking to bypass the kgdb test suite you have two options.

The kernel option that runs the tests on boot (which is not on by
default) is CONFIG_KGDB_TESTS_ON_BOOT, and make sure this is off.

You can turn off the tests in an already compiled kernel that had the
testing turned on with boot by adding the boot argument with nothing
on the other side of the = sign of the kgdbts paramter.  Like:

kgdbts=


In terms of debugging what happened, if you have console output you
can save, please do send me the output of kernel boot with the kernel
boot argument:

kgdbts=V2

That enables verbose logging of exactly what is going on and will show
where wheels fall off the cart.  If the kernel is dying silently it
means the early exception code has completely failed in some way on
the kernel architecture that was selected, and of course the .config
is always useful in this case.

Thanks,
Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
