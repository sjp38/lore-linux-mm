Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 064D86B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 23:40:13 -0400 (EDT)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TOKUP-0005mn-1H
	for linux-mm@kvack.org; Wed, 17 Oct 2012 03:40:13 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so4290979eek.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 20:40:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016131933.c196457a.akpm@linux-foundation.org>
References: <1350403183-12650-1-git-send-email-ming.lei@canonical.com>
	<1350403183-12650-2-git-send-email-ming.lei@canonical.com>
	<20121016131933.c196457a.akpm@linux-foundation.org>
Date: Wed, 17 Oct 2012 11:40:12 +0800
Message-ID: <CACVXFVPXp8bK+A8xTZBWP5n43+S9qHQUg1VhiFVj9q7q+JfX8g@mail.gmail.com>
Subject: Re: [RFC PATCH v1 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 17, 2012 at 4:19 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> The patch seems reasonable to me.  I'd like to see some examples of
> these resume-time callsite which are performing the GFP_KERNEL
> allocations, please.  You have found some kernel bugs, so those should
> be fully described.

OK, there are two examples of GFP_KERNEL allocation in subsystem
runtime resume path:

1), almost all devices in some pci platform
acpi_os_allocate
	<-acpi_ut_allocate
		<-ACPI_ALLOCATE_ZEROED
			<-acpi_evaluate_object
				<-__acpi_bus_set_power
					<-acpi_bus_set_power
						<-acpi_pci_set_power_state
							<-platform_pci_set_power_state
								<-pci_platform_power_transition
									<-__pci_complete_power_transition
										<-pci_set_power_state
											<-pci_restore_standard_config
												<-pci_pm_runtime_resume

2), all devices in usb subsystem
usb_get_status
	<-finish_port_resume
		<-usb_port_resume
			<-generic_resume
				<-usb_resume_device
					<-usb_resume_both
						<-usb_runtime_resume	

I also have many examples in which GFP_KERNEL allocation
is involved in runtime resume path of individual drivers.

The above two examples just show how difficult to solve the problem
by traditional way, :-)

Also as pointed by Oliver, network driver need memory allocation with
no io in iSCSI runtime resume situation too.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
