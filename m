Received: by nf-out-0910.google.com with SMTP id x30so145781nfb
        for <linux-mm@kvack.org>; Sat, 29 Jul 2006 17:02:50 -0700 (PDT)
Message-ID: <44CBF731.7010008@gmail.com>
Date: Sun, 30 Jul 2006 02:02:34 +0159
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: swsusp regression (s2dsk) [Was: 2.6.18-rc2-mm1]
References: <20060727015639.9c89db57.akpm@osdl.org> <200607292059.59106.rjw@sisk.pl> <44CBE9D5.9030707@gmail.com> <200607300110.01943.rjw@sisk.pl>
In-Reply-To: <200607300110.01943.rjw@sisk.pl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Jiri Slaby <jirislaby@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, pavel@suse.cz, linux-pm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rafael J. Wysocki napsal(a):
> On Sunday 30 July 2006 01:06, Jiri Slaby wrote:
>> Rafael J. Wysocki napsal(a):
>>> Hi,
>>>
>>> On Saturday 29 July 2006 19:58, Jiri Slaby wrote:
>>>> Andrew Morton napsal(a):
>>>>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/
>>>> Hello,
>>>>
>>>> I have problems with swsusp again. While suspending, the very last thing kernel
>>>> writes is 'restoring higmem' and then hangs, hardly. No sysrq response at all.
>>>> Here is a snapshot of the screen:
>>>> http://www.fi.muni.cz/~xslaby/sklad/swsusp_higmem.gif
>>>>
>>>> It's SMP system (HT), higmem enabled (1 gig of ram).
>>> Most probably it hangs in device_power_up(), so the problem seems to be
>>> with one of the devices that are resumed with IRQs off.
>>>
>>> Does vanila .18-rc2 work?
>> Yup, it does.
> 
> Hm, in fact this may be a problem with any device driver.

Note 1: 2.6.18-rc1-mm2 was(is) working just fine.
Note 2: when I was going through these -mm diff, the culprit may be radeon
driver -- there are some PM changes... Or if you want to go on your own, here is
lspci output:
00:00.0 Host bridge: Intel Corporation 82865G/PE/P DRAM Controller/Host-Hub
Interface (rev 02)
00:01.0 PCI bridge: Intel Corporation 82865G/PE/P PCI to AGP Controller (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
Controller #3 (rev 02)
00:1d.3 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
Controller #4 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB2 EHCI
Controller (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev c2)
00:1f.0 ISA bridge: Intel Corporation 82801EB/ER (ICH5/ICH5R) LPC Interface
Bridge (rev 02)
00:1f.1 IDE interface: Intel Corporation 82801EB/ER (ICH5/ICH5R) IDE Controller
(rev 02)
00:1f.2 IDE interface: Intel Corporation 82801EB (ICH5) SATA Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801EB/ER (ICH5/ICH5R) SMBus Controller (rev 02)
01:00.0 VGA compatible controller: ATI Technologies Inc Radeon RV250 If [Radeon
9000] (rev 01)
01:00.1 Display controller: ATI Technologies Inc Radeon RV250 [Radeon 9000]
(Secondary) (rev 01)
02:02.0 Multimedia audio controller: Creative Labs SB Live! EMU10k1 (rev 0a)
02:02.1 Input device controller: Creative Labs SB Live! Game Port (rev 0a)
02:05.0 FireWire (IEEE 1394): Texas Instruments TSB43AB23 IEEE-1394a-2000
Controller (PHY/Link)
02:08.0 Ethernet controller: Intel Corporation 82562EZ 10/100 Ethernet
Controller (rev 02)

with -n:
00:00.0 0600: 8086:2570 (rev 02)
00:01.0 0604: 8086:2571 (rev 02)
00:1d.0 0c03: 8086:24d2 (rev 02)
00:1d.1 0c03: 8086:24d4 (rev 02)
00:1d.2 0c03: 8086:24d7 (rev 02)
00:1d.3 0c03: 8086:24de (rev 02)
00:1d.7 0c03: 8086:24dd (rev 02)
00:1e.0 0604: 8086:244e (rev c2)
00:1f.0 0601: 8086:24d0 (rev 02)
00:1f.1 0101: 8086:24db (rev 02)
00:1f.2 0101: 8086:24d1 (rev 02)
00:1f.3 0c05: 8086:24d3 (rev 02)
01:00.0 0300: 1002:4966 (rev 01)
01:00.1 0380: 1002:496e (rev 01)
02:02.0 0401: 1102:0002 (rev 0a)
02:02.1 0980: 1102:7002 (rev 0a)
02:05.0 0c00: 104c:8024
02:08.0 0200: 8086:1050 (rev 02)

regards,
-- 
<a href="http://www.fi.muni.cz/~xslaby/">Jiri Slaby</a>
faculty of informatics, masaryk university, brno, cz
e-mail: jirislaby gmail com, gpg pubkey fingerprint:
B674 9967 0407 CE62 ACC8  22A0 32CC 55C3 39D4 7A7E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
