Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id DCBCA6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 05:04:58 -0400 (EDT)
Date: Mon, 5 Aug 2013 11:04:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] MM: Make Contiguous Memory Allocator depends on MMU
Message-ID: <20130805090455.GG10146@dhcp22.suse.cz>
References: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
 <51fe08c6.87ef440a.10fc.1786SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAJFYCKEhJtG1x1PaiwpwOADxthXRSh0pQsE3uYWO2i4xnHGvYQ@mail.gmail.com>
 <20130805073239.GC10146@dhcp22.suse.cz>
 <CAJFYCKGZte3FER8MNRX3T_c=jgYbCb+WEWtdz4wSPa9XZ8huGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJFYCKGZte3FER8MNRX3T_c=jgYbCb+WEWtdz4wSPa9XZ8huGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manjunath Goudar <manjunath.goudar@linaro.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, patches@linaro.org, arnd@linaro.org, dsaxena@linaro.org, linaro-kernel@lists.linaro.org, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hyojun.im@lge.com, Nataraja KM/LGSIA CSP-4 <nataraja.km@lge.com>

On Mon 05-08-13 14:07:41, Manjunath Goudar wrote:
> On 5 August 2013 13:02, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 05-08-13 10:10:08, Manjunath Goudar wrote:
> > > On 4 August 2013 13:24, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> > >
> > > > On Sun, Aug 04, 2013 at 10:41:01AM +0530, Manjunath Goudar wrote:
> > > > >s patch adds a Kconfig dependency on an MMU being available before
> > > > >CMA can be enabled.  Without this patch, CMA can be enabled on an
> > > > >MMU-less system which can lead to issues. This was discovered during
> > > > >randconfig testing, in which CMA was enabled w/o MMU being enabled,
> > > > >leading to the following error:
> > > > >
> > > > > CC      mm/migrate.o
> > > > >mm/migrate.c: In function a??remove_migration_ptea??:
> > > > >mm/migrate.c:134:3: error: implicit declaration of function
> > > > a??pmd_trans_hugea??
> > > > >[-Werror=implicit-function-declaration]
> > > > >   if (pmd_trans_huge(*pmd))
> > > > >   ^
> > > > >mm/migrate.c:137:3: error: implicit declaration of function
> > > > a??pte_offset_mapa??
> > > > >[-Werror=implicit-function-declaration]
> > > > >   ptep = pte_offset_map(pmd, addr);
> > > > >
> > > >
> > > > Similar one.
> > > >
> > > > http://marc.info/?l=linux-mm&m=137532486405085&w=2
> > >
> > >
> > > In this patch MIGRATION config is not required MMU, because already CMA
> > > config depends
> > > on MMU and HAVE_MEMBLOCK if both are true then only selecting MIGRATION
> > and
> > > MEMORY_ISOLATION.
> >
> > No, I think it should be config MIGRATION that should depend on MMU
> > explicitly because that is where the problem exists. It shouldn't rely
> > on other configs to not select it automatically.
> >
> >  Yes you are correct.
> 
> > The question is. Does CMA need to depend on MMU as well? Why?
> > But please comment on the original thread instead.
> >
> 
> I went through the mm/Kconfig, I think MMU dependence is not required
> for CMA.

OK, it turned out that it is needed in the end. Kcofing forces selects
so CMA config would force MIGRATION even if that one depends on MMU.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
