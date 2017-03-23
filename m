Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84F8F6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 10:47:49 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 15so59147754itw.1
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 07:47:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g17si3415539ita.71.2017.03.23.07.47.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 07:47:48 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
 <20170319151837.GD12414@dhcp22.suse.cz>
 <555d1f95-7c9e-2691-b14f-0260f90d23a9@wiesinger.com>
 <1489979147.4273.22.camel@gmx.de>
 <798104b6-091d-5415-2c51-8992b6b231e5@wiesinger.com>
 <1490080422.14658.39.camel@gmx.de>
 <1ce2621b-0573-0cc7-a1df-49d6c68df792@wiesinger.com>
 <1490258325.27756.42.camel@gmx.de>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <113bf774-7f7c-4128-d614-7c16dd9ecd67@I-love.SAKURA.ne.jp>
Date: Thu, 23 Mar 2017 23:46:26 +0900
MIME-Version: 1.0
In-Reply-To: <1490258325.27756.42.camel@gmx.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>, Gerhard Wiesinger <lists@wiesinger.com>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 2017/03/23 17:38, Mike Galbraith wrote:
> On Thu, 2017-03-23 at 08:16 +0100, Gerhard Wiesinger wrote:
>> On 21.03.2017 08:13, Mike Galbraith wrote:
>>> On Tue, 2017-03-21 at 06:59 +0100, Gerhard Wiesinger wrote:
>>>
>>>> Is this the correct information?
>>> Incomplete, but enough to reiterate cgroup_disable=memory
>>> suggestion.
>>>
>>
>> How to collect complete information?
> 
> If Michal wants specifics, I suspect he'll ask.  I posted only to pass
> along a speck of information, and offer a test suggestion.. twice.
> 
> 	-Mike

Isn't information Mike asked something like output from below command

  for i in `find /sys/fs/cgroup/memory/ -type f`; do echo ========== $i ==========; cat $i | xargs echo; done

and check which cgroups stalling tasks belong to? Also, Mike suggested to
reproduce your problem with cgroup_disable=memory kernel command line option
in order to bisect whether memory cgroups are related to your problem.

I don't know whether Michal already knows specific information to collect.
I think memory allocation watchdog might give us some clue. It will give us
output like http://I-love.SAKURA.ne.jp/tmp/serial-20170321.txt.xz .

Can you afford building kernels with watchdog patch applied? Steps I tried for
building kernels are shown below. (If you can't afford building but can afford
trying binary rpms, I can upload them.)

----------------------------------------
yum -y install yum-utils
wget https://dl.fedoraproject.org/pub/alt/rawhide-kernel-nodebug/SRPMS/kernel-4.11.0-0.rc3.git0.1.fc27.src.rpm
yum-builddep -y kernel-4.11.0-0.rc3.git0.1.fc27.src.rpm
rpm -ivh kernel-4.11.0-0.rc3.git0.1.fc27.src.rpm
yum-builddep -y ~/rpmbuild/SPECS/kernel.spec
patch -p1 -d ~/rpmbuild/SPECS/ << "EOF"
--- a/kernel.spec
+++ b/kernel.spec
@@ -24,7 +24,7 @@
 %global zipsed -e 's/\.ko$/\.ko.xz/'
 %endif
 
-# define buildid .local
+%define buildid .kmallocwd
 
 # baserelease defines which build revision of this kernel version we're
 # building.  We used to call this fedora_build, but the magical name
@@ -1207,6 +1207,8 @@
 
 git am %{patches}
 
+patch -p1 < $RPM_SOURCE_DIR/kmallocwd.patch
+
 # END OF PATCH APPLICATIONS
 
 # Any further pre-build tree manipulations happen here.
@@ -1243,6 +1245,8 @@
 do
   cat $i > temp-$i
   mv $i .config
+  echo 'CONFIG_DETECT_MEMALLOC_STALL_TASK=y' >> .config
+  echo 'CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT=30' >> .config
   Arch=`head -1 .config | cut -b 3-`
   make ARCH=$Arch listnewconfig | grep -E '^CONFIG_' >.newoptions || true
 %if %{listnewconfig_fail}
EOF
wget -O ~/rpmbuild/SOURCES/kmallocwd.patch 'https://marc.info/?l=linux-mm&m=148957858821214&q=raw'
rpmbuild -bb ~/rpmbuild/SPECS/kernel.spec
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
